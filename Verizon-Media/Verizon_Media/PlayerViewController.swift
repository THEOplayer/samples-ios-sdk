//
//  PlayerViewController.swift
//  Basic_Playback
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

    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupPlayerView()
        setupTheoplayer()
        // Configure the player's source to initilaise playback
        // let verizonMediaSource = createMultiAssetFairPlayStream()
        let verizonMediaSource = createHLSStreamWithAds()
        let sourceDescription = SourceDescription(verizonMediaSource: verizonMediaSource)
        theoplayer.source = sourceDescription
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

    // MARK: - THEOplayer setup and unload

    private func setupTheoplayer() {
        
        let theoplayerConfiguration = THEOplayerConfiguration(
            pip: nil,
            license: "your_license_string",
            verizonMedia: VerizonMediaConfiguration(
                defaultSkipOffset: 15, // optional; defaults to -1 (=unskippable)
                onSeekOverAd: SkippedAdStrategy.PLAY_LAST, // optional; default to PLAY_NONE
                ui: VerizonMediaUiConfiguration(
                    contentNotification: true, // optional; default to true
                    adNotification: true, // optional; default to true
                    assetMarkers: true, // optional; default to true
                    adBreakMarkers: true // optional; default to true
                )
            )
        )
        
        // Instantiate player object
        theoplayer = THEOplayer(configuration: theoplayerConfiguration)

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
        listeners["preplayresponse"] = theoplayer.verizonMedia.addEventListener(type: VerizonMediaResponseEventTypes.PREPLAY_RESPONSE, listener: onPreplayResponse)
        listeners["pingresponse"] = theoplayer.verizonMedia.addEventListener(type: VerizonMediaResponseEventTypes.PING_RESPONSE, listener: onPingResponse)
        listeners["addadbreak"] = theoplayer.verizonMedia.ads.adBreaks.addEventListener(type: VerizonMediaAdBreakArrayEventTypes.ADD_AD_BREAK, listener: onAddAdbreak)
        listeners["removeadbreak"] = theoplayer.verizonMedia.ads.adBreaks.addEventListener(type: VerizonMediaAdBreakArrayEventTypes.REMOVE_AD_BREAK, listener: onRemoveAdbreak)
        
    }

    private func removeEventListeners() {
        // Remove event listeners
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAY, listener: listeners["play"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAYING, listener: listeners["playing"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PAUSE, listener: listeners["pause"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ENDED, listener: listeners["ended"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ERROR, listener: listeners["error"]!)
        theoplayer.verizonMedia.removeEventListener(type: VerizonMediaResponseEventTypes.PREPLAY_RESPONSE, listener: listeners["preplayresponse"]!)
        theoplayer.verizonMedia.removeEventListener(type: VerizonMediaResponseEventTypes.PING_RESPONSE, listener: listeners["pingresponse"]! )
        theoplayer.verizonMedia.ads.adBreaks.removeEventListener(type: VerizonMediaAdBreakArrayEventTypes.ADD_AD_BREAK, listener: listeners["addadbreak"]!)
        theoplayer.verizonMedia.ads.adBreaks.removeEventListener(type: VerizonMediaAdBreakArrayEventTypes.REMOVE_AD_BREAK, listener: listeners["removeadbreak"]!)

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
    
    private func onPreplayResponse(event: VerizonMediaPreplayResponseEvent) {
        os_log("PREPLAYRESPONSE, event: %f", event.response.debugDescription)
    }
    
    private func onPingResponse(event: VerizonMediaPingResponseEvent) {
        os_log("PINGRESPONSE, event: %f", event.response.debugDescription)
    }
    
    private func onAddAdbreak(event: VerizonMediaAddAdBreakEvent) {
        os_log("ADDADBREAK, event: %f", event.adBreak!.duration!)
        event.adBreak?.ads.forEach({ (ad) in
            ad.addEventListener(type: VerizonMediaAdEventTypes.AD_BEGIN, listener: onAdBegin)
            ad.addEventListener(type: VerizonMediaAdEventTypes.AD_END, listener: onAdEnd)
        })
        event.adBreak?.addEventListener(type: VerizonMediaAdBreakEventTypes.AD_BREAK_BEGIN, listener: onAdBreakBegin(event:))
        event.adBreak?.addEventListener(type: VerizonMediaAdBreakEventTypes.AD_BREAK_END, listener: onAdBreakEnd)
        event.adBreak?.addEventListener(type: VerizonMediaAdBreakEventTypes.AD_BREAK_SKIP, listener: onAdBreakSkip)
        event.adBreak?.addEventListener(type: VerizonMediaAdBreakEventTypes.AD_BREAK_UPDATE, listener: onAdBreakUpdate)
    }
    
    private func onRemoveAdbreak(event: VerizonMediaRemoveAdBreakEvent) {
        os_log("REMOVEADBREAK, event: %f", event.adBreak!.duration!)
    }
    
    private func onAdBreakBegin(event: VerizonMediaAdBreakBeginEvent) {
        os_log("ADBREAKBEGIN, event: %f", event.adBreak!.ads.count)
    }
    
    private func onAdBreakEnd(event: VerizonMediaAdBreakEndEvent) {
        os_log("ADBREAKEND, event: %f", event.adBreak!.ads.count)
    }
    
    private func onAdBreakSkip(event: VerizonMediaAdBreakSkipEvent) {
        os_log("ADBREAKSIP, event: %f", event.adBreak!.ads.count)
    }
    
    private func onAdBreakUpdate(event: VerizonMediaAdBreakUpdateEvent) {
        os_log("ADBREAKUPDATE, event: %f", event.adBreak!.ads.count)
    }
    
    private func onAdBegin(event: VerizonMediaAdBeginEvent) {
        os_log("ADBEGIN, event: %f", event.ad!.duration)
    }
    
    private func onAdEnd(event: VerizonMediaAdEndEvent) {
        os_log("ADEND, event: %f", event.ad!.duration)
    }
    
    /*
     The functions below will create a VerizonMediaSource based
     on the assets available at https://cdn.theoplayer.com/demos/verizon-media/index.html.
     */
    
    private func createMultiAssetFairPlayStream() -> VerizonMediaSource {
        let verizonMediaSource = VerizonMediaSource(
            assetIds: ["e973a509e67241e3aa368730130a104d",
            "e70a708265b94a3fa6716666994d877d"],
            assetType: .ASSET, // Optional, defaults to ".ASSET". Can also be ".CHANNEL" or ".EVENT", following the Verizon Media semantics, where 'asset' is On-demand content.
            contentProtected: true // Optional, defaults to false.
        )
        return verizonMediaSource
    }
    
    private func createLiveFairPlayStreamWithAds() -> VerizonMediaSource {
        let verizonMediaSource = VerizonMediaSource(
            assetId: "3c367669a83b4cdab20cceefac253684",
            orderedParameters: [ // preplay query parameters
                ("ad", "cleardashnew")
            ],
            assetType: .CHANNEL,
            contentProtected: true, // Optional, defaults to false.
            ping: VerizonMediaPingConfiguration(linearAdData: true, adImpressions: false, freeWheelVideoViews: false)
        )

        return verizonMediaSource
    }
    
    private func createHLSStreamWithAds() -> VerizonMediaSource {
        let verizonMediaSource = VerizonMediaSource(
            assetIds: [
                "41afc04d34ad4cbd855db52402ef210e",
                "c6b61470c27d44c4842346980ec2c7bd",
                "588f9d967643409580aa5dbe136697a1",
                "b1927a5d5bd9404c85fde75c307c63ad",
                "7e9932d922e2459bac1599938f12b272",
                "a4c40e2a8d5b46338b09d7f863049675",
                "bcf7d78c4ff94c969b2668a6edc64278"
            ],
            orderedParameters: [ // preplay query parameters
                ("ad", "adtest"),
                ("ad.lib", "15_sec_spots")
            ],
            assetType: .ASSET,
            contentProtected: false // Optional, defaults to false.
        )

        return verizonMediaSource
    }
    
}
