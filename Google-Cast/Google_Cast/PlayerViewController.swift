//
//  PlayerViewController.swift
//  Google_Cast
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

    // Chromecast button on the navigation bar
    private var chromeCastButton: UIBarButtonItem!

    // Dictionary of player event listeners
    private var listeners: [String: EventListener] = [:]

    private var source: SourceDescription {
        // Declare a TypedSource object with a stream URL and its type
        let typedSource = TypedSource(
            src: videoUrl,
            type: mimeType
        )

        // Declare Chromecast metadata description object that defines metadata to be display on the casting device
        let chromecastMetadataDescription = ChromecastMetadataDescription(
            images: [
                ChromecastMetadataImage(
                    src: posterUrl,
                    width: posterWidth,
                    height: posterHeight)
                ],
            releaseDate: nil,
            title: streamTitle,
            subtitle: nil,
            type: nil,
            metadataKeys: nil
        )

        // Returns a computed SourceDescription object
        return SourceDescription(source: typedSource, poster: posterUrl, metadata: chromecastMetadataDescription)
    }

    // MARK: - Public properties

    // Default video URL
    var videoUrl: String = "https://cdn.theoplayer.com/video/elephants-dream/playlist.m3u8"
    // Default poster URL
    var posterUrl: String = "https://cdn.theoplayer.com/video/elephants-dream/playlist.png"
    // MIME type of the URL
    var mimeType: String = "application/x-mpegURL"
    // Chromecast metadata
    var streamTitle: String  = "Elephants Dream"
    var posterWidth: Int = 420
    var posterHeight: Int = 240

    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupPlayerView()
        setupchromeCast()
        setupTheoplayer()
        // Configure the player's source to initilaise playback
        theoplayer.source = source

        // To set custom cast source
             /*
             if var chromecast = theoplayer.cast?.chromecast {
                 chromecast.source = SourceDescription(source:
                     TypedSource(
                         src: videoUrl,
                         type: mimeType
                     )
                 )
             }
              */
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

    private func setupchromeCast() {
        // Use the default THEOplayer cast options
        THEOplayerCastHelper.setGCKCastContextSharedInstanceWithDefaultCastOptions()

        // Setup chromecast button and set it as right button of the navigation bar
        chromeCastButton = UIBarButtonItem(image: UIImage(named: "ic_cast_black_24dp"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(onChromecast))
        chromeCastButton.tintColor = .theoWhite
        // Disable by default. To be enabled in state change callback when casting device is avaiable
        chromeCastButton.isEnabled = false

        navigationItem.rightBarButtonItem = chromeCastButton
    }

    // MARK: - Chromecast button handler

    @objc private func onChromecast() {
        if let cast = theoplayer.cast, let chromecast = cast.chromecast {
            if chromecast.casting {
                chromecast.leave()
            } else {
                chromecast.start()
            }
        } else {
            os_log("Chromecast module is not available in THEOplayer SDK.")
        }
    }

    // MARK: - THEOplayer setup and unload

    private func setupTheoplayer() {
        // Configure cast join strategy to auto
        let playerConfig = THEOplayerConfiguration(cast: CastConfiguration(strategy: .auto))

        // Instantiate player object with playerConfig
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

        // Add chromecast listeners
        if let cast = theoplayer.cast, let chromecast = cast.chromecast {
            listeners["castStateChange"] = chromecast.addEventListener(type: ChromecastEventTypes.STATE_CHANGE, listener: onCastStateChange)
            listeners["castError"] = chromecast.addEventListener(type: ChromecastEventTypes.ERROR, listener: onCastError)
        }
    }

    private func removeEventListeners() {
        // Remove event listenrs
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAY, listener: listeners["play"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAYING, listener: listeners["playing"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PAUSE, listener: listeners["pause"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ENDED, listener: listeners["ended"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ERROR, listener: listeners["error"]!)

        // Remove chromecast listeners
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

        // Toggle the chromecast button and set image based on the current chromecast state
        if event.state != .unavailable {
            chromeCastButton.isEnabled = true
            if event.state == .connected {
                chromeCastButton.image = UIImage(named: "ic_cast_connected_black_24dp")
            } else {
                chromeCastButton.image = UIImage(named: "ic_cast_black_24dp")
            }
        } else {
            chromeCastButton.isEnabled = false
        }
    }

    private func onCastError(event: CastErrorEvent) {
        os_log("Chromecast ERROR event, error: %@", event.error.errorCode.rawValue)
    }
}
