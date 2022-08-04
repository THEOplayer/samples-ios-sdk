//
//  PlayerViewController.swift
//  Related-Content
//
//  Created by savdeep on 18/05/2020.
//  Copyright © 2020 THEOplayer. All rights reserved.
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

        // Configure the player's source to initilaise playback
        theoplayer.source = source
        
        //create a variable to decalare related content sources to the player.
        var relatedContent = self.theoplayer?.related
        
        //Create an array variable with your related content sources.
        var relatedSources = [RelatedContentSource]()
                        relatedSources.append(RelatedContentSource(image: "https://cdn.theoplayer.com/video/vr/poster.jpg", source: source, title: "Stream 1"))
                        
                        relatedSources.append(RelatedContentSource(image: "https://cdn.theoplayer.com/video/sintel/poster.jpg", source: source, title: "Stream 2"))

                        relatedSources.append(RelatedContentSource(image: "https://cdn.theoplayer.com/video/big_buck_bunny/poster.jpg", source: source, title: "Stream 3"))

                        relatedSources.append(RelatedContentSource(image: "https://cdn2.hubspot.net/hubfs/2163521/Demo_zone/tears_of_steel_poster.jpg", source: source, title: "Stream 4"))

                        relatedSources.append(RelatedContentSource(image: "https://cdn.theoplayer.com/video/vr/poster.jpg", source: source, title: "Stream 5"))

                        relatedSources.append(RelatedContentSource(image: "https://cdn.theoplayer.com/video/vr/poster.jpg", source: source, title: "Stream 6"))

        //Add the relatedSources array to the created relatedContent variable.
        relatedContent?.sources = relatedSources
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

    private func setupPlayerView() {
        theoplayerView = THEOPlayerView() { [weak self] (updatedFrame) in
            guard let viewController = self else { return }
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
        // Adding the CSS external file
        let stylePath = Bundle.main.path(forResource:"stylesheet", ofType: "css")!
        
        // Setting the CSS files to player configuration
        let playerConfig = THEOplayerConfiguration(
            defaultCSS: true,
            cssPaths:[stylePath],
            pip: nil,
            license: "your_license_string"
        )
        
        // Adding player configuration to THEOplayer
        theoplayer = THEOplayer(configuration: playerConfig)

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
    }

    private func removeEventListeners() {
        // Remove event listenrs
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAY, listener: listeners["play"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAYING, listener: listeners["playing"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PAUSE, listener: listeners["pause"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ENDED, listener: listeners["ended"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ERROR, listener: listeners["error"]!)

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
}

