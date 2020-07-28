//
//  PlayerViewController.swift
//  Custom_UI
//
//  Copyright © 2019 THEOPlayer. All rights reserved.
//

import UIKit
import os.log
import THEOplayerSDK

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
        setupPlayerInterfaceView()
        setupTheoplayer()
        // Initialising control interface view based on device orientation
               if UIDevice.current.orientation == .portrait {
                   inlinePlayerInterfaceView()
               } else {
                   fullscreenPlayerInterfaceView()
               }

        // Initialing playerInterfaceView state to set its UI components.
        playerInterfaceView.state = .initialise

        // Configure the player's source to initilaise playback
        theoplayer.source = source
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if (self.isMovingFromParent){
                     unloadTheoplayer()
                 }
    }

    // MARK: - View setup

    private func setupView() {
        // Set the background colour to THEO blue
        view.backgroundColor = .theoCello
    }

    private func setupPlayerView() {
        theoplayerView = THEOPlayerView() { (updatedFrame) in
            // Create a frame based on the playView's updated frame
            var playerFrame = updatedFrame

            // Reset the origin 0 to prevent unnecessary offset
            playerFrame.origin = .zero

            // Assign the frame to THEOplayer. Closure might be invoked prior to THEOplayer initialisation hence the optional chaining
            self.theoplayer?.frame = playerFrame
        }
        // Disable automatic auto layout constraints
        theoplayerView.translatesAutoresizingMaskIntoConstraints = false

        // Add the playerView to view controller's view hierarchy
        view.addSubview(theoplayerView)

        let safeArea = view.safeAreaLayoutGuide
        // Position playerView at the center of the safe area
        theoplayerView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        theoplayerView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor).isActive = true
        // Set width and height using the width and height of the safe area
        theoplayerView.widthAnchor.constraint(equalTo: safeArea.widthAnchor).isActive = true
        theoplayerView.heightAnchor.constraint(equalTo: safeArea.heightAnchor).isActive = true
    }

    private func setupPlayerInterfaceView() {
        playerInterfaceView = PlayerInterfaceView()
        playerInterfaceView.delegate = self
    }

    // MARK: - Controller interface view rezie functions

    private func inlinePlayerInterfaceView() {
        /* For inline mode, add playerInterfaceView as the subview of
            theoplayerView and apply constraints.
            This function will be called on returning from fullscreen to inline
            mode in which case playerInterfaceView will be removed
            automatically from the keyWindow and so as the associated constraints
         */
        theoplayerView.addSubview(playerInterfaceView)

        playerInterfaceView.leadingAnchor.constraint(equalTo: theoplayerView.leadingAnchor).isActive = true
        playerInterfaceView.trailingAnchor.constraint(equalTo: theoplayerView.trailingAnchor).isActive = true
        playerInterfaceView.topAnchor.constraint(equalTo: theoplayerView.topAnchor).isActive = true
        playerInterfaceView.bottomAnchor.constraint(equalTo: theoplayerView.bottomAnchor).isActive = true

        // Ensure interface is the top subview of theoplayerView
        theoplayerView.insertSubview(playerInterfaceView, at: theoplayerView.subviews.count)
    }

    private func fullscreenPlayerInterfaceView() {
        if let window = UIApplication.shared.keyWindow {
            /* For fullscreen mode, add playerInterfaceView as the subview of
                keyWindow and apply constraints as there is no access to the
                FullscreenViewController from the theoplayer object.
                playerInterfaceView will be removed automatically from
                the theoplayerView and so as the associated constraints
             */
            window.addSubview(playerInterfaceView)

            playerInterfaceView.leadingAnchor.constraint(equalTo: window.leadingAnchor).isActive = true
            playerInterfaceView.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
            playerInterfaceView.topAnchor.constraint(equalTo: window.topAnchor).isActive = true
            playerInterfaceView.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
        }
    }

    // MARK: - THEOplayer setup and unload

    private func setupTheoplayer() {
        // Enable chromeless flag in THEOplayer configuration
        let playerConfig = THEOplayerConfiguration(chromeless: true)

        // Instantiate player object
        theoplayer = THEOplayer(configuration: playerConfig)

        // Coupling fullscreen with device orientation so that rotation will trigger fullscreen
        theoplayer.fullscreenOrientationCoupling = true

        // Add the player to playerView's view hierarchy
        theoplayer.addAsSubview(of: theoplayerView)

        attachEventListeners()
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
        if event.presentationMode == .inline {
            inlinePlayerInterfaceView()
        }
        if event.presentationMode == .fullscreen {
            fullscreenPlayerInterfaceView()
        }
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
        theoplayer.requestCurrentTime { (time, error) in
            if let timeInSeconds = time {
                var newTime = timeInSeconds + (isForward ? 10 : -10)
                // Make sure newTime is not less than 0
                newTime = newTime < 0 ? 0 : newTime
                if let duration = self.theoplayer.duration {
                    // Make sure newTime is not bigger than duration
                    newTime = newTime > duration ? duration : newTime
                }
                self.seek(timeInSeconds: Float(newTime))
            }
        }
    }

    func seek(timeInSeconds: Float) {
        // Set current time will trigger waiting event
        theoplayer.setCurrentTime(Double(timeInSeconds))
        playerInterfaceView.currentTime = timeInSeconds
    }
}
