//
//  PlayerViewController.swift
//  Full_Screen_Handling
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

    // Vertical UIStackView for UI components
    private var vStackView: UIStackView!

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

    private let videoTitle: String = "Now watching Elephants Dream"
    private let videoDescription: String = "Friends Proog and Emo journey inside the folds of a seemingly infinite Machine, exploring the dark and twisted complex of wires, gears, and cogs, until a moment of conflict negates all their assumptions."
    private let fullscreenButtonTitle: String = "FULLSCREEN"

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
        setupStackView()
        setupTitleLabel()
        setupPlayerView()
        setupDescriptionLabel()
        setupFullscreenButton()
        setupTheoplayer()
        // Configure the player's source to initilaise playback
        theoplayer.source = source
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (self.isMovingFromParent){
            unloadTheoplayer()
        }
    }

    // MARK: - View setup

    private func setupView() {
        // Set the background colour to THEO blue
        view.backgroundColor = .theoCello
    }

    private func setupStackView() {
        vStackView = THEOComponent.stackView()

        view.addSubview(vStackView)

        let safeArea = view.safeAreaLayoutGuide
        // Constaints to fix a margin around the vStackView
        vStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10).isActive = true
        vStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 10).isActive = true
        vStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -10).isActive = true
        vStackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -20).isActive = true
    }

    private func setupTitleLabel() {
        let title = THEOComponent.label(text: videoTitle)
        title.numberOfLines = 0
        title.textColor = .theoWhite
        vStackView.addArrangedSubview(title)
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

        // Add the playerView to vStackView view hierarchy
        vStackView.addArrangedSubview(theoplayerView)

        // Set theoplayerView aspect ratio to 16 : 9 using the width anchor of vStackView
        theoplayerView.widthAnchor.constraint(equalTo: vStackView.widthAnchor).isActive = true
        theoplayerView.heightAnchor.constraint(equalTo: vStackView.widthAnchor, multiplier: 9 / 16).isActive = true
    }

    private func setupDescriptionLabel() {
        let description = THEOComponent.label(text: videoDescription)
        description.numberOfLines = 0
        description.textColor = .theoWhite
        vStackView.addArrangedSubview(description)
    }

    private func setupFullscreenButton() {
        let buttonWrapper = THEOComponent.stackView(spacing: 10)
        // Set alignment to center instead of fill (default) so that subview will not fill all the space
        buttonWrapper.alignment = .center

        let fullscreenButton = THEOComponent.textButton(text: fullscreenButtonTitle)
        fullscreenButton.addTarget(self, action: #selector(onButtonPressed), for: .touchUpInside)
        // Add button to wrapper stackview
        buttonWrapper.addArrangedSubview(fullscreenButton)

        vStackView.addArrangedSubview(buttonWrapper)
    }

    // MARK: - THEOplayer setup and unload

    private func setupTheoplayer() {
        // Instantiate player object
        theoplayer = THEOplayer()
        
        //Add FullScreen Handling Orientation
        theoplayer.fullscreen.setSupportedInterfaceOrientations(supportedInterfaceOrientations: .landscapeRight)

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
        listeners["presentationmodechange"] = theoplayer.addEventListener(type: PlayerEventTypes.PRESENTATION_MODE_CHANGE, listener: onPresentationModeChange)
    }

    private func removeEventListeners() {
        // Remove event listenrs
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAY, listener: listeners["play"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAYING, listener: listeners["playing"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PAUSE, listener: listeners["pause"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ENDED, listener: listeners["ended"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ERROR, listener: listeners["error"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PRESENTATION_MODE_CHANGE, listener: listeners["presentationmodechange"]!)

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

    private func onPresentationModeChange(event: PresentationModeChangeEvent) {
        os_log("onPresentationModeChange: %@", event.presentationMode.rawValue)
        // Set device to portrait when theoplayer exit from fullscreen mode. This is added to handle the case when user uses THEOplayer UI to exit full screen mode when device remains in landscape
        if event.presentationMode == .inline {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }

    // MARK: - @objc functions

    @objc func onButtonPressed() {
        // Setting theoplayer presentation mode will trigger screen rotation
        theoplayer.presentationMode = .fullscreen
    }
}
