//
//  PlayerViewController.swift
//  Simple_OTT
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

    // Dictionary of player event listeners
    private var listeners: [String: EventListener] = [:]

    // MARK: - Public property

    // Source description object to be played
    var source: SourceDescription? = nil

    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupPlayerView()
        navigationController?.navigationBar.isHidden = false
        setupTheoplayer()
        // Configure the player’s source to initilaise playback
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
        theoplayerView = THEOPlayerView() { [weak self] (updatedFrame) in
            guard let theoplayer = self?.theoplayer,
                  theoplayer.presentationMode == .inline else { return }

            // Create a frame based on the playView's updated frame
            var playerFrame = updatedFrame

            // Reset the origin 0 to prevent unnecessary offset
            playerFrame.origin = .zero

            // Assign the frame to THEOplayer. Closure might be invoked prior to THEOplayer initialisation hence the optional chaining
            theoplayer.frame = playerFrame
        }
        // Disable automatic auto layout constraints
        theoplayerView.translatesAutoresizingMaskIntoConstraints = false

        // Add the playerView to view controller’s view hierarchy
        view.addSubview(theoplayerView)

        let safeArea = view.safeAreaLayoutGuide
        // Position playerView at the center of the safe area
        theoplayerView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
        theoplayerView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor).isActive = true
        // Set width and height using the width and height of the safe area
        theoplayerView.widthAnchor.constraint(equalTo: safeArea.widthAnchor).isActive = true
        theoplayerView.heightAnchor.constraint(equalTo: safeArea.heightAnchor).isActive = true
    }

    // MARK: - THEOplayer setup and unload

    private func setupTheoplayer() {
        // Use the default THEOplayer cast options
        THEOplayerCastHelper.setGCKCastContextSharedInstanceWithDefaultCastOptions()

        // Enable googleIMA, picture-in-picture and configure cast join strategy to auto
        let playerConfig = THEOplayerConfiguration(chromeless: false, pip: PiPConfiguration(retainPresentationModeOnSourceChange: true), ads: AdsConfiguration(showCountdown: true, preload: .NONE, googleImaConfiguration: GoogleIMAConfiguration(useNativeIma: true)), cast: CastConfiguration(strategy: .auto), license: "your_license_string")

        // Instantiate player object with playerConfig
        theoplayer = THEOplayer(configuration: playerConfig)

        // Enable autoplay
        theoplayer.autoplay = true

        // Coupling fullscreen with device orientation so that rotation will trigger fullscreen
        theoplayer.fullscreenOrientationCoupling = true

        // Add the player to playerView’s view hierarchy
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

        if let cast = theoplayer.cast, let chromeast = cast.chromecast {
            listeners["castStateChange"] = chromeast.addEventListener(type: ChromecastEventTypes.STATE_CHANGE, listener: onCastStateChange)
            listeners["castError"] = chromeast.addEventListener(type: ChromecastEventTypes.ERROR, listener: onCastError)
        }
    }

    private func removeEventListeners() {
        // Remove event listenrs
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAY, listener: listeners["play"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAYING, listener: listeners["playing"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PAUSE, listener: listeners["pause"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ENDED, listener: listeners["ended"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ERROR, listener: listeners["error"]!)

        if let cast = theoplayer.cast, let _ = cast.chromecast  {
            theoplayer.removeEventListener(type: ChromecastEventTypes.STATE_CHANGE, listener: listeners["castStateChange"]!)
            theoplayer.removeEventListener(type: ChromecastEventTypes.ERROR, listener: listeners["castError"]!)
        }

        listeners.removeAll()
    }

    private func onPlay(event: PlayEvent) {
        os_log("PLAY event, currentTime: %f", event.currentTime)
    }

    private func onPlaying(event: PlayingEvent) {
        os_log("PLAYING event, currentTime: %f", event.currentTime)
    }

    private func onPause(event: PauseEvent) {
        os_log("PAUSE event, currentTime: %f", event.currentTime)
    }

    private func onEnded(event: EndedEvent) {
        os_log("ENDED event, currentTime: %f", event.currentTime)
    }

    private func onError(event: ErrorEvent) {
        os_log("ERROR event, error: %@", event.error)
    }

    private func onCastStateChange(event: StateChangeEvent) {
        os_log("Chromecast STATE_CHANGE event, state: %@", event.state.rawValue)
    }

    private func onCastError(event: CastErrorEvent) {
        os_log("Chromecast ERROR event, error: %@", event.error.errorCode.rawValue)
    }
}
