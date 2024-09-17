//
//  PlayerViewController.swift
//
//  Copyright © 2024 THEOPlayer. All rights reserved.
//

import UIKit
import os.log
import THEOplayerSDK

// MARK: - PlayerView declaration

class PlayerViewController: UIViewController {
    // MARK: - Private properties

    // THEOPlayerView for the player
    private var theoplayerView: THEOPlayerView!
    // View contains custom player interface
    private var playerInterfaceView: PlayerInterfaceView!
    // Dictionary of player event listeners
    private var listeners: [String: EventListener] = [:]

    // MARK: - Public properties

    // THEOplayer object
    var theoplayer: THEOplayer!
    // Default poster URL
    var posterUrl: String = "https://cdn.theoplayer.com/video/elephants-dream/playlist.png"

    // Declare a TypedSource object with a stream URL and its type
    var typedSource: TypedSource {
        // Default video URL
        let videoUrl: String = "https://cdn.theoplayer.com/video/elephants-dream/playlist.m3u8"
        // MIME type of the URL
        let mimeType: String = "application/x-mpegURL"
        return .init(
            src: videoUrl,
            type: mimeType
        )
    }

    // Returns a computed SourceDescription object
    var source: SourceDescription {
        return .init(
            source: self.typedSource,
            poster: self.posterUrl
        )
    }

    var adPlaying: Bool {
        let integrations: [Integration] = self.theoplayer.getAllIntegrations()
        if (integrations.first { $0.type == .ADS }) != nil,
           self.theoplayer.ads.playing {
            return true
        }
        return false
    }

    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
        self.setupPlayerView()
        self.setupTheoplayer()
        self.setupPlayerInterfaceView()
        self.setupIntegrations()
        self.attachEventListeners()

        // Initialing playerInterfaceView state to set its UI components.
        self.playerInterfaceView.state = .initialise
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if self.isBeingDismissed {
            self.unloadTheoplayer()
        }
    }

    func setupIntegrations() {}

    // MARK: - View setup

    private func setupView() {
        // Set the background colour to THEO blue
        self.view.backgroundColor = .theoCello
    }

    private func setupPlayerView() {
        self.theoplayerView = THEOPlayerView() { [weak self] updatedFrame in
            guard let viewController = self,
                  viewController.theoplayer.presentationMode == .inline else { return }

            // Create a frame based on the playView's updated frame
            var playerFrame: CGRect = updatedFrame

            // Reset the origin 0 to prevent unnecessary offset
            playerFrame.origin = .zero

            // Assign the frame to THEOplayer. Closure might be invoked prior to THEOplayer initialisation hence the optional chaining
            viewController.theoplayer?.frame = playerFrame
        }

        // Disable automatic auto layout constraints
        self.theoplayerView.translatesAutoresizingMaskIntoConstraints = false

        // Add the playerView to view controller's view hierarchy
        self.view.addSubview(self.theoplayerView)
        self.theoplayerView.setConstraintsToSafeArea(safeArea: self.view.safeAreaLayoutGuide)
    }

    private func setupPlayerInterfaceView() {
        self.playerInterfaceView = PlayerInterfaceView()
        self.playerInterfaceView.delegate = self

        self.theoplayerView.addSubview(self.playerInterfaceView)

        self.playerInterfaceView.leadingAnchor.constraint(equalTo: self.theoplayerView.leadingAnchor).isActive = true
        self.playerInterfaceView.trailingAnchor.constraint(equalTo: self.theoplayerView.trailingAnchor).isActive = true
        self.playerInterfaceView.topAnchor.constraint(equalTo: self.theoplayerView.topAnchor).isActive = true
        self.playerInterfaceView.bottomAnchor.constraint(equalTo: self.theoplayerView.bottomAnchor).isActive = true

        // Ensure interface is the top subview of theoplayerView
        self.theoplayerView.insertSubview(playerInterfaceView, at: self.theoplayerView.subviews.count)
    }

    // MARK: - THEOplayer setup and unload

    private func setupTheoplayer() {
        // Enable chromeless flag in THEOplayer configuration
        let playerConfigBuilder = THEOplayerConfigurationBuilder()
        // playerConfigBuilder.license = "<your_license_string>"

        // Instantiate player object
        self.theoplayer = THEOplayer(configuration: playerConfigBuilder.build())

        // Coupling fullscreen with device orientation so that rotation will trigger fullscreen
        self.theoplayer.fullscreenOrientationCoupling = true

        // Add the player to playerView's view hierarchy
        self.theoplayer.addAsSubview(of: theoplayerView)

        var fullscreen: Fullscreen = self.theoplayer.fullscreen
        fullscreen.presentationDelegate = self
    }

    private func unloadTheoplayer() {
        self.removeEventListeners()
        self.theoplayer.stop()
    }

    // MARK: - THEOplayer listener related functions and closures

    private func attachEventListeners() {
        // Listen to event and store references in dictionary
        self.listeners["play"] = self.theoplayer.addEventListener(type: PlayerEventTypes.PLAY, listener: self.onPlay)
        self.listeners["playing"] = self.theoplayer.addEventListener(type: PlayerEventTypes.PLAYING, listener: self.onPlaying)
        self.listeners["pause"] = self.theoplayer.addEventListener(type: PlayerEventTypes.PAUSE, listener: self.onPause)
        self.listeners["ended"] = self.theoplayer.addEventListener(type: PlayerEventTypes.ENDED, listener: self.onEnded)
        self.listeners["error"] = self.theoplayer.addEventListener(type: PlayerEventTypes.ERROR, listener: self.onError)

        self.listeners["sourceChange"] = self.theoplayer.addEventListener(type: PlayerEventTypes.SOURCE_CHANGE, listener: self.onSourceChange)
        self.listeners["readyStateChange"] = self.theoplayer.addEventListener(type: PlayerEventTypes.READY_STATE_CHANGE, listener: self.onReadyStateChange)
        self.listeners["waiting"] = self.theoplayer.addEventListener(type: PlayerEventTypes.WAITING, listener: self.onWaiting)
        self.listeners["durationChange"] = self.theoplayer.addEventListener(type: PlayerEventTypes.DURATION_CHANGE, listener: self.onDurationChange)
        self.listeners["timeUpdate"] = self.theoplayer.addEventListener(type: PlayerEventTypes.TIME_UPDATE, listener: self.onTimeUpdate)
        self.listeners["presentationModeChange"] = self.theoplayer.addEventListener(type: PlayerEventTypes.PRESENTATION_MODE_CHANGE, listener: self.onPresentationModeChange)

        self.listeners["adBreakBegin"] = self.theoplayer.ads.addEventListener(type: AdsEventTypes.AD_BREAK_BEGIN, listener: self.onAdBreakBegin)
        self.listeners["adBreakEnd"] = self.theoplayer.ads.addEventListener(type: AdsEventTypes.AD_BREAK_END, listener: self.onAdBreakEnd)
    }

    private func removeEventListeners() {
        // Remove event listenrs
        self.theoplayer.removeEventListener(type: PlayerEventTypes.PLAY, listener: self.listeners["play"]!)
        self.theoplayer.removeEventListener(type: PlayerEventTypes.PLAYING, listener: self.listeners["playing"]!)
        self.theoplayer.removeEventListener(type: PlayerEventTypes.PAUSE, listener: self.listeners["pause"]!)
        self.theoplayer.removeEventListener(type: PlayerEventTypes.ENDED, listener: self.listeners["ended"]!)
        self.theoplayer.removeEventListener(type: PlayerEventTypes.ERROR, listener: self.listeners["error"]!)

        self.theoplayer.removeEventListener(type: PlayerEventTypes.SOURCE_CHANGE, listener: self.listeners["sourceChange"]!)
        self.theoplayer.removeEventListener(type: PlayerEventTypes.READY_STATE_CHANGE, listener: self.listeners["readyStateChange"]!)
        self.theoplayer.removeEventListener(type: PlayerEventTypes.WAITING, listener: self.listeners["waiting"]!)
        self.theoplayer.removeEventListener(type: PlayerEventTypes.DURATION_CHANGE, listener: self.listeners["durationChange"]!)
        self.theoplayer.removeEventListener(type: PlayerEventTypes.TIME_UPDATE, listener: self.listeners["timeUpdate"]!)
        self.theoplayer.removeEventListener(type: PlayerEventTypes.PRESENTATION_MODE_CHANGE, listener: self.listeners["presentationModeChange"]!)

        self.theoplayer.removeEventListener(type: AdsEventTypes.AD_BREAK_BEGIN, listener: self.listeners["adBreakBegin"]!)
        self.theoplayer.removeEventListener(type: AdsEventTypes.AD_BREAK_END, listener: self.listeners["adBreakEnd"]!)

        self.listeners.removeAll()
    }

    private func onPlay(event: PlayEvent) {
        os_log("PLAY event, currentTime: %f", event.currentTime)
        if self.playerInterfaceView.state == .initialise {
            self.playerInterfaceView.state = .buffering
        }
        if self.adPlaying {
            self.playerInterfaceView.state = .adplaying
        }
    }

    private func onPlaying(event: PlayingEvent) {
        os_log("PLAYING event, currentTime: %f", event.currentTime)
        self.playerInterfaceView.state = .playing
    }

    private func onPause(event: PauseEvent) {
        os_log("PAUSE event, currentTime: %f", event.currentTime)
        // Pause might be triggered when Application goes into background which should be ignored if playback is not started yet
        if self.playerInterfaceView.state != .initialise {
            self.playerInterfaceView.state = self.adPlaying ? .adpaused : .paused
        }
    }

    private func onEnded(event: EndedEvent) {
        os_log("ENDED event, currentTime: %f", event.currentTime)
        // Stop player
        self.theoplayer.stop()
        // Set the same source to restart playback
        self.theoplayer.source = source
    }

    private func onError(event: ErrorEvent) {
        os_log("ERROR event, error: %@", event.error)
    }

    private func onSourceChange(event: SourceChangeEvent) {
        os_log("SOURCE_CHANGE event, url: %@", event.source?.sources[0].src.absoluteString ?? "")
        // Initialise UI on source change
        self.playerInterfaceView.state = .initialise
    }

    private func onReadyStateChange(event: ReadyStateChangeEvent) {
        os_log("READY_STATE_CHANGE event, state: %d", event.readyState.rawValue)
        // Restore the appropriate UI state if there is enough data
        if event.readyState == .HAVE_ENOUGH_DATA {
            self.playerInterfaceView.state = self.theoplayer?.paused ?? false ? .paused : .playing
        }
    }

    private func onWaiting(event: WaitingEvent) {
        os_log("WAITING event, currentTime: %f", event.currentTime)
        // Waiting event indicates there is not enough data to play, hence the buffering state
        self.playerInterfaceView.state = .buffering
    }

    private func onDurationChange(event: DurationChangeEvent) {
        os_log("DURATION_CHANGE event, duration: %f", event.duration ?? 0.0)
        // Set UI duration
        if let duration: Double = event.duration,
           duration.isNormal {
            self.playerInterfaceView.duration = Float(duration)
        }
    }

    private func onTimeUpdate(event: TimeUpdateEvent) {
        os_log("TIME_UPDATE event, currentTime: %f", event.currentTime)
        // Update UI current time
        if !self.theoplayer.seeking {
            self.playerInterfaceView.currentTime = Float(event.currentTime)
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
        self.theoplayer.play()
    }

    func pause() {
        self.theoplayer.pause()
    }

    func skip(isForward: Bool) {
        var newTime: Double = self.theoplayer.currentTime + (isForward ? 10 : -10)
        // Make sure newTime is not less than 0
        newTime = newTime < 0 ? 0 : newTime
        if let duration: Double = self.theoplayer.duration {
            // Make sure newTime is not bigger than duration
            newTime = newTime > duration ? duration : newTime
        }
        self.seek(timeInSeconds: Float(newTime))
    }

    func seek(timeInSeconds: Float) {
        // Set current time will trigger waiting event
        self.theoplayer.currentTime = Double(timeInSeconds)
        self.playerInterfaceView.currentTime = timeInSeconds
    }
}

// MARK: - FullscreenPresentationDelegate

extension PlayerViewController: FullscreenPresentationDelegate {
    func present(viewController: THEOplayerSDK.FullscreenViewController, completion: @escaping () -> Void) {
        self.present(viewController, animated: true) {
            viewController.view.addSubview(self.playerInterfaceView)
            self.playerInterfaceView.setConstraintsToSafeArea(safeArea: viewController.view.safeAreaLayoutGuide)
            completion()
        }
    }

    func dismiss(viewController: THEOplayerSDK.FullscreenViewController, completion: @escaping () -> Void) {
        viewController.presentingViewController?.dismiss(animated: false) {
            self.theoplayerView.insertSubview(self.playerInterfaceView, at: self.theoplayerView.subviews.count)
            self.playerInterfaceView.leadingAnchor.constraint(equalTo: self.theoplayerView.leadingAnchor).isActive = true
            self.playerInterfaceView.trailingAnchor.constraint(equalTo: self.theoplayerView.trailingAnchor).isActive = true
            self.playerInterfaceView.topAnchor.constraint(equalTo: self.theoplayerView.topAnchor).isActive = true
            self.playerInterfaceView.bottomAnchor.constraint(equalTo: self.theoplayerView.bottomAnchor).isActive = true
            completion()
        }
    }
}
