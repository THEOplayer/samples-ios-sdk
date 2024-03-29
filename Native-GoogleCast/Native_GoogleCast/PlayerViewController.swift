//
//  PlayerViewController.swift
//  Native_GoogleCast
//
//  Copyright © 2023 THEOPlayer. All rights reserved.
//

import UIKit
import os.log
import THEOplayerSDK
import THEOplayerGoogleCastIntegration
import GoogleCast

// MARK: - THEOPlayerView declaration

class THEOPlayerView: UIView {

    // MARK: - Type alias

    // Closure that provides latest frame when layout is updated
    typealias frameUpdatedClosure = (CGRect) -> Void

    // MARK: - Private property

    private var frameUpdated: frameUpdatedClosure? = nil

    // MARK: - Convenience initializer

    convenience init(frameUpdated: @escaping frameUpdatedClosure) {
        self.init()
        // Store provided closure in private property
        self.frameUpdated = frameUpdated
    }

    // MARK: - View layout

    override func layoutSubviews() {
        super.layoutSubviews()

        // Call frameUpdated closure with the latest frame
        frameUpdated?(frame)
    }

    func setConstraintsToSafeArea(safeArea: UILayoutGuide) {
        // Position playerView at the center of the safe area
        self.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor).isActive = true
        // Set width and height using the width and height of the safe area
        self.widthAnchor.constraint(equalTo: safeArea.widthAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: safeArea.heightAnchor).isActive = true
    }
}

// MARK: - PlayerView declaration

class PlayerViewController: UIViewController {

    // MARK: - Private properties

    // THEOPlayerView for the player
    private var theoplayerView: THEOPlayerView!

    // Chromecast button on the navigation bar
    private var chromeCastButton: GCKUICastButton!

    // THEOplayer object
    private var theoplayer: THEOplayer!

    // View contains custom player interface
    private var playerInterfaceView: PlayerInterfaceView!

    // Dictionary of player event listeners
    private var listeners: [String: EventListener] = [:]

    private var source: SourceDescription {
        // Declare a TypedSource object with a stream URL and its type
        let typedSource = TypedSource(
            src: videoUrl,
            type: mimeType
        )

        // Returns a computed SourceDescription object
        return SourceDescription(source: typedSource, poster: posterUrl)
    }

    // MARK: - Public properties

    // Default video URL
    var videoUrl: String = "https://cdn.theoplayer.com/video/elephants-dream/playlist.m3u8"
    // Default poster URL
    var posterUrl: String = "https://cdn.theoplayer.com/video/elephants-dream/playlist.png"
    // MIME type of the URL
    var mimeType: String = "application/x-mpegURL"

    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupPlayerView()
        setupTheoplayer()
        setupPlayerInterfaceView()
        setupCastIntegration()
        prepareCustomChromecastLogic()

        // Initialing playerInterfaceView state to set its UI components.
        playerInterfaceView.state = .initialise

        // Configure the player's source to initialise playback
        theoplayer.source = source
        theoplayer.play()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if self.isMovingFromParent {
            unloadTheoplayer()
        }
    }

    // MARK: - View setup

    private func setupView() {
        // Set the background colour to THEO blue
        view.backgroundColor = .theoCello
    }

    private func setupPlayerView() {
        theoplayerView = THEOPlayerView() { [weak self] (updatedFrame) in
            guard let viewController = self,
                  viewController.theoplayer.presentationMode == .inline else { return }

            // Create a frame based on the playView's updated frame
            var playerFrame = updatedFrame

            // Reset the origin 0 to prevent unnecessary offset
            playerFrame.origin = .zero

            // Assign the frame to THEOplayer. Closure might be invoked prior to THEOplayer initialisation hence the optional chaining
            viewController.theoplayer?.frame = playerFrame
        }
        // Disable automatic auto layout constraints
        theoplayerView.translatesAutoresizingMaskIntoConstraints = false

        // Add the playerView to view controller's view hierarchy
        view.addSubview(theoplayerView)
        theoplayerView.setConstraintsToSafeArea(safeArea: view.safeAreaLayoutGuide)
    }

    private func setupPlayerInterfaceView() {
        playerInterfaceView = PlayerInterfaceView()
        playerInterfaceView.delegate = self

        theoplayerView.addSubview(playerInterfaceView)

        playerInterfaceView.leadingAnchor.constraint(equalTo: theoplayerView.leadingAnchor).isActive = true
        playerInterfaceView.trailingAnchor.constraint(equalTo: theoplayerView.trailingAnchor).isActive = true
        playerInterfaceView.topAnchor.constraint(equalTo: theoplayerView.topAnchor).isActive = true
        playerInterfaceView.bottomAnchor.constraint(equalTo: theoplayerView.bottomAnchor).isActive = true

        // Ensure interface is the top subview of theoplayerView
        theoplayerView.insertSubview(playerInterfaceView, at: theoplayerView.subviews.count)
    }

    // MARK: - THEOplayer setup and unload

    private func setupTheoplayer() {
        // Enable chromeless flag in THEOplayer configuration
        let playerConfig = THEOplayerConfiguration(
            chromeless: true
            /*,license: "your_license_string"*/
        )

        // Instantiate player object
        theoplayer = THEOplayer(configuration: playerConfig)

        // Coupling fullscreen with device orientation so that rotation will trigger fullscreen
        theoplayer.fullscreenOrientationCoupling = true

        // Add the player to playerView's view hierarchy
        theoplayer.addAsSubview(of: theoplayerView)

        attachEventListeners()
        
        var fullscreen: Fullscreen = self.theoplayer.fullscreen
        fullscreen.presentationDelegate = self
    }

    private func setupCastIntegration() {
        let castConfiguration: CastConfiguration = CastConfiguration(strategy: .manual)
        let castIntegration: THEOplayerSDK.Integration = GoogleCastIntegrationFactory.createIntegration(on: self.theoplayer, with: castConfiguration)
        theoplayer.addIntegration(castIntegration)
    }

    private func prepareCustomChromecastLogic() {
        // Set up Chromecast button
        self.chromeCastButton = GCKUICastButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(24), height: CGFloat(24)))

        self.chromeCastButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.chromeCastButton!)

        self.chromeCastButton.delegate = self
    }

    private func unloadTheoplayer() {
        removeEventListeners()
        theoplayer.stop()
        theoplayer.destroy()
    }

    // MARK: - THEOplayer listener related functions and closures

    private func attachEventListeners() {
        // Listen to event and store references in dictionary
        listeners["play"] = theoplayer.addEventListener(type: PlayerEventTypes.PLAY, listener: onPlay)
        listeners["playing"] = theoplayer.addEventListener(type: PlayerEventTypes.PLAYING, listener: onPlaying)
        listeners["pause"] = theoplayer.addEventListener(type: PlayerEventTypes.PAUSE, listener: onPause)
        listeners["ended"] = theoplayer.addEventListener(type: PlayerEventTypes.ENDED, listener: onEnded)
        listeners["error"] = theoplayer.addEventListener(type: PlayerEventTypes.ERROR, listener: onError)

        listeners["sourceChange"] = theoplayer.addEventListener(type: PlayerEventTypes.SOURCE_CHANGE, listener: onSourceChange)
        listeners["readyStateChange"] = theoplayer.addEventListener(type: PlayerEventTypes.READY_STATE_CHANGE, listener: onReadyStateChange)
        listeners["waiting"] = theoplayer.addEventListener(type: PlayerEventTypes.WAITING, listener: onWaiting)
        listeners["durationChange"] = theoplayer.addEventListener(type: PlayerEventTypes.DURATION_CHANGE, listener: onDurationChange)
        listeners["timeUpdate"] = theoplayer.addEventListener(type: PlayerEventTypes.TIME_UPDATE, listener: onTimeUpdate)
        listeners["presentationModeChange"] = theoplayer.addEventListener(type: PlayerEventTypes.PRESENTATION_MODE_CHANGE, listener: onPresentationModeChange)
    }

    private func removeEventListeners() {
        // Remove event listenrs
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAY, listener: listeners["play"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAYING, listener: listeners["playing"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PAUSE, listener: listeners["pause"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ENDED, listener: listeners["ended"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ERROR, listener: listeners["error"]!)

        theoplayer.removeEventListener(type: PlayerEventTypes.SOURCE_CHANGE, listener: listeners["sourceChange"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.READY_STATE_CHANGE, listener: listeners["readyStateChange"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.WAITING, listener: listeners["waiting"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.DURATION_CHANGE, listener: listeners["durationChange"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.TIME_UPDATE, listener: listeners["timeUpdate"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PRESENTATION_MODE_CHANGE, listener: listeners["presentationModeChange"]!)

        listeners.removeAll()
    }

    private func onPlay(event: PlayEvent) {
        os_log("PLAY event, currentTime: %f", event.currentTime)
        if playerInterfaceView.state == .initialise {
            playerInterfaceView.state = .buffering
        }
    }

    private func onPlaying(event: PlayingEvent) {
        os_log("PLAYING event, currentTime: %f", event.currentTime)
        playerInterfaceView.state = .playing
    }

    private func onPause(event: PauseEvent) {
        os_log("PAUSE event, currentTime: %f", event.currentTime)
        // Pause might be triggered when Application goes into background which should be ignored if playback is not started yet
        if playerInterfaceView.state != .initialise {
            playerInterfaceView.state = .paused
        }
    }

    private func onEnded(event: EndedEvent) {
        os_log("ENDED event, currentTime: %f", event.currentTime)
        // Stop player
        theoplayer.stop()
        // Set the same source to restart playback
        theoplayer.source = source
    }

    private func onError(event: ErrorEvent) {
        os_log("ERROR event, error: %@", event.error)
    }

    private func onSourceChange(event: SourceChangeEvent) {
        os_log("SOURCE_CHANGE event, url: %@", event.source?.sources[0].src.absoluteString ?? "")
        // Initialise UI on source change
        playerInterfaceView.state = .initialise
    }

    private func onReadyStateChange(event: ReadyStateChangeEvent) {
        os_log("READY_STATE_CHANGE event, state: %d", event.readyState.rawValue)
        // Restore the appropriate UI state if there is enough data
        if event.readyState == .HAVE_ENOUGH_DATA {
            playerInterfaceView.state = theoplayer?.paused ?? false ? .paused : .playing
        }
    }

    private func onWaiting(event: WaitingEvent) {
        os_log("WAITING event, currentTime: %f", event.currentTime)
        // Waiting event indicates there is not enough data to play, hence the buffering state
        playerInterfaceView.state = .buffering
    }

    private func onDurationChange(event: DurationChangeEvent) {
        os_log("DURATION_CHANGE event, duration: %f", event.duration ?? 0.0)
        // Set UI duration
        if let duration = event.duration, duration.isNormal {
            playerInterfaceView.duration = Float(duration)
        }
    }

    private func onTimeUpdate(event: TimeUpdateEvent) {
        os_log("TIME_UPDATE event, currentTime: %f", event.currentTime)
        // Update UI current time
        if !theoplayer.seeking {
            playerInterfaceView.currentTime = Float(event.currentTime)
        }
    }

    private func onPresentationModeChange(event: PresentationModeChangeEvent) {
        os_log("PRESENTATION_MODE_CHANGE event, presentationMode: %d", event.presentationMode.rawValue)
    }
}

// MARK: - PlayerInterfaceViewDelegate

extension PlayerViewController: PlayerInterfaceViewDelegate {
    func play() {
        theoplayer.play()
    }

    func pause() {
        theoplayer.pause()
    }

    func skip(isForward: Bool) {
        var newTime = theoplayer.currentTime + (isForward ? 10 : -10)
        // Make sure newTime is not less than 0
        newTime = newTime < 0 ? 0 : newTime
        if let duration = theoplayer.duration {
            // Make sure newTime is not bigger than duration
            newTime = newTime > duration ? duration : newTime
        }
        seek(timeInSeconds: Float(newTime))
    }

    func seek(timeInSeconds: Float) {
        // Set current time will trigger waiting event
        theoplayer.currentTime = Double(timeInSeconds)
        playerInterfaceView.currentTime = timeInSeconds
    }
}

// MARK: - FullscreenPresentationDelegate

extension PlayerViewController: FullscreenPresentationDelegate {
    func present(viewController: THEOplayerSDK.FullscreenViewController, completion: @escaping () -> Void) {
        self.present(viewController, animated: true) {
            viewController.view.addSubview(self.theoplayerView)
            self.theoplayerView.setConstraintsToSafeArea(safeArea: viewController.view.safeAreaLayoutGuide)
            completion()
        }
    }

    func dismiss(viewController: THEOplayerSDK.FullscreenViewController, completion: @escaping () -> Void) {
        viewController.presentingViewController?.dismiss(animated: false) {
            self.view.addSubview(self.theoplayerView)
            self.theoplayerView.setConstraintsToSafeArea(safeArea: self.view.safeAreaLayoutGuide)
            completion()
        }
    }
}

extension PlayerViewController: GCKUICastButtonDelegate {
    // Workaround due to existing bug. Fix is due in the upcoming THEOplayer releases.
    // Avoid using the `castState: GCKCastState` parameter, instead use `theoplayer.cast.chromecast.state`.
    // Internally both of the above are in sync.
    func castButtonDidTap(_ castButton: GCKUICastButton, toPresentDialogFor castState: GCKCastState) {
        guard let chromecast = self.theoplayer.cast?.chromecast else {
            return
        }
        if chromecast.state == PlayerCastState.available {
            chromecast.start()
        } else if chromecast.state == PlayerCastState.connected || chromecast.state == PlayerCastState.connecting {
            chromecast.stop()
        }
    }
}
