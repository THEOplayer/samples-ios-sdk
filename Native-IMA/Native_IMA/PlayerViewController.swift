//
//  PlayerViewController.swift
//  Native_IMA
//
//  Copyright © 2023 THEOPlayer. All rights reserved.
//

import UIKit
import os.log
import THEOplayerSDK
import THEOplayerGoogleIMAIntegration

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

        // The AdDescription object that defines the IMA ad to be played.
        let adDescription: GoogleImaAdDescription = GoogleImaAdDescription(src: adTagUrl)

        // Returns a computed SourceDescription object
        return SourceDescription(
            source: typedSource,
            ads: [adDescription],
            poster: posterUrl
        )
    }

    // MARK: - Public properties

    // Default video URL
    var videoUrl: String = "https://cdn.theoplayer.com/video/elephants-dream/playlist.m3u8"
    // Default poster URL
    var posterUrl: String = "https://cdn.theoplayer.com/video/elephants-dream/playlist.png"
    // MIME type of the URL
    var mimeType: String = "application/x-mpegURL"
    // IMA ad tag URL
    var adTagUrl: String = "https://pubads.g.doubleclick.net/gampad/ads?slotname=/124319096/external/ad_rule_samples&sz=640x480&ciu_szs=300x250&cust_params=deployment%3Ddevsite%26sample_ar%3Dpreonly&url=https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/tags&unviewed_position_start=1&output=xml_vast3&impl=s&env=vp&gdfp_req=1&ad_rule=0&vad_type=linear&vpos=preroll&pod=1&ppos=1&lip=true&min_ad_duration=0&max_ad_duration=30000&vrid=5776&video_doc_id=short_onecue&cmsid=496&kfa=0&tfcd=0"

    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupPlayerView()
        setupTheoplayer()
        setupPlayerInterfaceView()
        setupImaIntegration()
        attachEventListeners()

        // Initialing playerInterfaceView state to set its UI components.
        playerInterfaceView.state = .initialise
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Configure the player's source to initialise playback.
        // If the source contains an AdDescription, then it must be called when viewDidAppear is called (or later) so that the IMAAdDisplayContainer is ready.
        // If the IMAAdDisplayContainer is not ready yet, then the IMAAdsRequest will fail.
        if theoplayer.source == nil {
            theoplayer.source = source
        }
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
        
        var fullscreen: Fullscreen = self.theoplayer.fullscreen
        fullscreen.presentationDelegate = self
    }

    private func setupImaIntegration() {
        let imaIntegration: THEOplayerSDK.Integration = GoogleIMAIntegrationFactory.createIntegration(on: self.theoplayer)
        theoplayer.addIntegration(imaIntegration)
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

        listeners["adBreakBegin"] = theoplayer.ads.addEventListener(type: AdsEventTypes.AD_BREAK_BEGIN, listener: onAdBreakBegin)
        listeners["adBreakEnd"] = theoplayer.ads.addEventListener(type: AdsEventTypes.AD_BREAK_END, listener: onAdBreakEnd)
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

        theoplayer.removeEventListener(type: AdsEventTypes.AD_BREAK_BEGIN, listener: listeners["adBreakBegin"]!)
        theoplayer.removeEventListener(type: AdsEventTypes.AD_BREAK_END, listener: listeners["adBreakEnd"]!)

        listeners.removeAll()
    }

    private func onPlay(event: PlayEvent) {
        os_log("PLAY event, currentTime: %f", event.currentTime)
        if playerInterfaceView.state == .initialise {
            playerInterfaceView.state = .buffering
        }
        if theoplayer.ads.playing {
            playerInterfaceView.state = .adplaying
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
            playerInterfaceView.state = theoplayer.ads.playing ? .adpaused : .paused
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

    private func onAdBreakBegin(event: AdBreakBeginEvent) {
        os_log("AD_BREAK_BEGIN event")
        self.playerInterfaceView.state = .adplaying
    }

    private func onAdBreakEnd(event: AdBreakEndEvent) {
        os_log("AD_BREAK_END event")
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
