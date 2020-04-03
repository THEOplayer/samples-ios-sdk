//
//  PlayerViewController.swift
//  Custom_Ads
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

    private var source: SourceDescription {
        // Declare a TypedSource object with a stream URL and its type
        let typedSource = TypedSource(
            src: videoUrl,
            type: mimeType
        )

        var adDescs: [AdDescription] = [AdDescription]()

        if adsUrl != "" {
            if adsType == "VMAP" {
                adDescs.append(GoogleImaAdDescription(src: adsUrl))
            } else {
                switch adPlacement {
                case "Pre-roll":
                    adDescs.append(GoogleImaAdDescription(src: adsUrl))
                case "Mid-roll":
                    adDescs.append(GoogleImaAdDescription(src: adsUrl, timeOffset: "2%"))
                case "Post-roll":
                    adDescs.append(GoogleImaAdDescription(src: adsUrl, timeOffset: "end"))
                default:
                    print("Unknown ad placement: \(adPlacement)")
                }
            }
        }
        // Returns a computed SourceDescription object with array of ads descriptors
        return SourceDescription(source: typedSource, ads: adDescs)
    }

    // MARK: - Public properties

    // Video URL
    var videoUrl: String = ""
    // MIME type of the URL
    var mimeType: String = "application/x-mpegURL"
    // Ad URL
    var adsUrl: String = ""
    // Type of ad
    var adsType: String = ""
    // Placement of ad
    var adPlacement: String = ""
    
    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupPlayerView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupTheoplayer()

        // Configure the player's source to initilaise playback
        theoplayer.source = source
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        unloadTheoplayer()
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

    // MARK: - THEOplayer setup and unload

    private func setupTheoplayer() {
        let playerConfig = THEOplayerConfiguration(googleIMA: true)
        // Instantiate player object with playerConfig
        theoplayer = THEOplayer(configuration: playerConfig)

        // Enable autoplay
        theoplayer.autoplay = true

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
        // Add ads event listeners
        listeners["adBegin"] = theoplayer.ads.addEventListener(type: AdsEventTypes.AD_BEGIN, listener: onAdBegin)
        listeners["adEnd"] = theoplayer.ads.addEventListener(type: AdsEventTypes.AD_END, listener: onAdEnd)
        listeners["adError"] = theoplayer.ads.addEventListener(type: AdsEventTypes.AD_ERROR, listener: onAdError)
    }

    private func removeEventListeners() {
        // Remove event listenrs
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAY, listener: listeners["play"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAYING, listener: listeners["playing"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PAUSE, listener: listeners["pause"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ENDED, listener: listeners["ended"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ERROR, listener: listeners["error"]!)
        // Remove ads event listeners
        theoplayer.ads.removeEventListener(type: AdsEventTypes.AD_BEGIN, listener: listeners["adBegin"]!)
        theoplayer.ads.removeEventListener(type: AdsEventTypes.AD_END, listener: listeners["adEnd"]!)
        theoplayer.ads.removeEventListener(type: AdsEventTypes.AD_ERROR, listener: listeners["adError"]!)
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

    private func onAdBegin(event: AdBeginEvent) {
        os_log("AD_BEGIN event, adId: %@", event.ad?.id ?? "nil")
    }

    private func onAdEnd(event: AdEndEvent) {
        os_log("AD_END event, adId: %@", event.ad?.id ?? "nil")
    }

    private func onAdError(event: AdErrorEvent) {
        os_log("AD_ERROR event, adId: %@, error: %@", event.ad?.id ?? "nil", event.error ?? "nil")
    }
}
