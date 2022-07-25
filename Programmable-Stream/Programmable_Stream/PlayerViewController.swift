//
//  PlayerViewController.swift
//  Programmable_Stream
//
//  Copyright © 2019 THEOPlayer. All rights reserved.
//

import UIKit
import os.log
import THEOplayerSDK
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
}

// MARK: - PlayerView declaration

class PlayerViewController: UIViewController {

    // MARK: - Private properties

    // THEOPlayerView for the player
    private var theoplayerView: THEOPlayerView!

    private var playerViewContainer: UIView!
    private var metadataContainer: UIView!
    private var tabbedMetadataView: TabbedMetadataView!

    // Array of portrait and landscape speccific constraints
    private var portraitConstaints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    private var landscapeConstaints: [NSLayoutConstraint] = [NSLayoutConstraint]()

    // THEOplayer object
    private var theoplayer: THEOplayer!

    // Dictionary of player event listeners
    private var listeners: [String: EventListener] = [:]

    private var source: SourceDescription? {
        // Reset tabbedMetadataView
        tabbedMetadataView.reset()

        // Empty eisting player logs
        playerLogs = ""

        // Return source description from remoteConfig
        return remoteConfig?.source
    }

    // Property to accumulate player event logs
    private var playerLogs: String = ""

    // Parsed remote configuration
    var remoteConfig: RemoteConfig? = nil

    // MARK: - View controller life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupPlayerViewContainer()
        setupPlayerView()
        setupMetadataContainer()
        setupTabbedMetadataView()
        // Set initial orientation constraints
        setOrientationConstraints()
        setupTheoplayer()
        // Configure the player's source to initilaise playback
        theoplayer.source = source
    }

    override func viewDidDisappear(_ animated: Bool) {
           super.viewDidDisappear(animated)

           if (self.isMovingFromParent){
              unloadTheoplayer()
          }
       }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { _ in
            // Update constaints on rotation
            self.setOrientationConstraints()
        })
        super.willTransition(to: newCollection, with: coordinator)
    }

    // MARK: - View setup

    private func setupView() {
        // Set the background colour to THEO blue
        view.backgroundColor = .theoCello
    }

    private func setupPlayerViewContainer() {
        playerViewContainer = THEOComponent.view()

        view.addSubview(playerViewContainer)

        let safeArea = view.safeAreaLayoutGuide
        playerViewContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true

        // Appending portrait constraints
        portraitConstaints += [
            playerViewContainer.topAnchor.constraint(equalTo: safeArea.topAnchor),
            playerViewContainer.widthAnchor.constraint(equalTo: safeArea.widthAnchor)
        ]

        // Appending landscape constraints
        landscapeConstaints += [
            playerViewContainer.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            playerViewContainer.widthAnchor.constraint(equalTo: safeArea.widthAnchor, multiplier: 0.5)
        ]
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
        playerViewContainer.addSubview(theoplayerView)

        // Set theoplayerView aspect ratio to 16 : 9 using the width anchor of vStackView
        theoplayerView.heightAnchor.constraint(equalTo: theoplayerView.widthAnchor, multiplier: 9 / 16).isActive = true
        theoplayerView.widthAnchor.constraint(equalTo: playerViewContainer.widthAnchor).isActive = true
        theoplayerView.leadingAnchor.constraint(equalTo: playerViewContainer.leadingAnchor).isActive = true
        theoplayerView.topAnchor.constraint(equalTo: playerViewContainer.topAnchor).isActive = true
        theoplayerView.bottomAnchor.constraint(equalTo: playerViewContainer.bottomAnchor).isActive = true
    }

    private func setupMetadataContainer() {
        metadataContainer = THEOComponent.view()

        view.addSubview(metadataContainer)
        metadataContainer.widthAnchor.constraint(equalTo: theoplayerView.widthAnchor).isActive = true

        let safeArea = view.safeAreaLayoutGuide
        metadataContainer.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true

        // Appending portrait constraints
        portraitConstaints += [
            metadataContainer.topAnchor.constraint(equalTo: theoplayerView.bottomAnchor),
            metadataContainer.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor)
        ]

        // Appending landscape constraints
        landscapeConstaints += [
            metadataContainer.topAnchor.constraint(equalTo: safeArea.topAnchor),
            metadataContainer.leadingAnchor.constraint(equalTo: theoplayerView.trailingAnchor)
        ]
    }

    private func setupTabbedMetadataView() {
        tabbedMetadataView = TabbedMetadataView()

        metadataContainer.addSubview(tabbedMetadataView)
        tabbedMetadataView.topAnchor.constraint(equalTo: metadataContainer.topAnchor).isActive = true
        tabbedMetadataView.bottomAnchor.constraint(equalTo: metadataContainer.bottomAnchor).isActive = true
        tabbedMetadataView.leadingAnchor.constraint(equalTo: metadataContainer.leadingAnchor).isActive = true
        tabbedMetadataView.trailingAnchor.constraint(equalTo: metadataContainer.trailingAnchor).isActive = true
    }

    // MARK: - THEOplayer setup and unload

    private func setupTheoplayer() {
        // Player config with Goolge IMA and picture-in-picture enabled
        let googleIMA = true

        var playerConfig: THEOplayerConfiguration!
        if let remoteConfig = remoteConfig, let playerConfiguration = remoteConfig.playerConfiguration {
            if let appId = playerConfiguration.cast?.chromecast?.appID {
                // Set Chromecast AppID via GCKCastContext option
                let options = GCKCastOptions(discoveryCriteria: GCKDiscoveryCriteria(applicationID: appId))
                GCKCastContext.setSharedInstanceWith(options)
            } else {
                // Use the default THEOplayer cast options
                THEOplayerCastHelper.setGCKCastContextSharedInstanceWithDefaultCastOptions()
            }

            playerConfig = playerConfiguration.getTheoPlayerConfiguration(googleIMA: googleIMA)
        } else {
            playerConfig = THEOplayerConfiguration(googleIMA: googleIMA)
        }

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

    // MARK: - Set constaints based on orientation

    private func setOrientationConstraints() {
        // Need to deactivate previous constraints set before activate the new set to avoid autolayout error
        if UIApplication.shared.statusBarOrientation.isLandscape {
            NSLayoutConstraint.deactivate(self.portraitConstaints)
            NSLayoutConstraint.activate(self.landscapeConstaints)
        } else {
            NSLayoutConstraint.deactivate(self.landscapeConstaints)
            NSLayoutConstraint.activate(self.portraitConstaints)
        }
    }

    // MARK: - Metadata process functions
    private func setTrackInfo() {
        for videoTrackIndex in 0..<theoplayer.videoTracks.count {
            let videoTrack = theoplayer.videoTracks.get(videoTrackIndex)
            self.tabbedMetadataView.setMetadata(
                type: .tracksInfo,
                dataStr:  """
                Video tracks:
                    ID: \(videoTrack.id)
                    Label: \(videoTrack.label)
                    Enabed: \(videoTrack.enabled)

                """,
                isAppending: false)
        }

        for audioTrackIndex in 0..<theoplayer.audioTracks.count {
            let audioTrack = theoplayer.audioTracks.get(audioTrackIndex)
            self.tabbedMetadataView.setMetadata(
                type: .tracksInfo,
                dataStr:  """
                Audio tracks:
                    ID: \(audioTrack.id)
                    Label: \(audioTrack.label)
                    Enabed: \(audioTrack.enabled)

                """)
        }

        for textTrackIndex in 0..<theoplayer.textTracks.count {
            let textTrack = theoplayer.textTracks.get(textTrackIndex)
            var cueInfo = "Active cues:\n"
            for activeCue in textTrack.activeCues {
                cueInfo += """
                        ID: \(activeCue.id)
                        Start time: \(activeCue.startTime ?? 0)
                        End time: \(activeCue.endTime ?? 0)
                """
            }
            self.tabbedMetadataView.setMetadata(
                type: .tracksInfo,
                dataStr:  """
                Text tracks:
                    ID: \(textTrack.id)
                    Label: \(textTrack.label)
                    Enabled: \(textTrack.mode == TextTrackMode.showing)
                    \(textTrack.activeCues.count > 0 ? "\(cueInfo)\n" : "")
                """)
        }
    }

    private func decimalPlaces(_ input: Double?) -> String {
        return String(format: "%.1f", input ?? 0.0)
    }

    private func trProcessor(_ timeranges: [TimeRange]?) -> String? {
        if let timeranges = timeranges, timeranges.count > 0 {
            var result = ""
            for (index, timeRange) in timeranges.enumerated() {
                let start = decimalPlaces(timeRange.start)
                let end = decimalPlaces(timeRange.end)
                result += "\(index != 0 ? ", " : "")\(start)s - \(end)s"
            }
            return result
        } else {
            return nil
        }
    }

    private func setTimeInfo() {
        guard tabbedMetadataView.selectedType == .timeInfo else {
            // Avoid unnecessary rapid time info retrieval for performance
            return
        }

        theoplayer.requestCurrentTime { (currentTime, _) in
            self.theoplayer.requestCurrentProgramDateTime { (currentProgramDateTime, _) in
                self.theoplayer.requestBuffered { (bufferedRange, _) in
                    self.theoplayer.requestPlayed { (playedRange, _) in
                        self.theoplayer.requestSeekable { (seekableRange, _) in
                            let ct = self.decimalPlaces(currentTime)
                            var cpdt = ""
                            if let date = currentProgramDateTime {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                cpdt = formatter.string(from: date)
                            }

                            let duration = self.decimalPlaces(self.theoplayer.duration ?? 0.0)

                            var br = ""
                            if let rangeStr = self.trProcessor(bufferedRange) {
                                br = "\nBuffered range: \(rangeStr)"
                            }
                            var pr = ""
                            if let rangeStr = self.trProcessor(playedRange) {
                                pr = "\nPlayed range: \(rangeStr)"
                            }
                            var sr = ""
                            if let rangeStr = self.trProcessor(seekableRange) {
                                sr = "\nSeekable range: \(rangeStr)"
                            }

                            self.tabbedMetadataView.setMetadata(
                                type: .timeInfo,
                                dataStr:  """
                                Current time: \(ct)s\(cpdt == "" ? "" : "\nCurrent program date time: \(cpdt)")
                                Duration: \(duration)s\(br)\(pr)\(sr)

                                """,
                                isAppending: false)
                        }
                    }
                }
            }
        }
    }

    private func setStateAndLogInfo(log: String? = nil) {
        let playerState = theoplayer.seeking ? "seeking" : (theoplayer.paused ? "pasued" : "playing")
        tabbedMetadataView.setMetadata(type: .stateAndLogs, dataStr: "The player is \(playerState)\n", isAppending: false)
        let preloadSetting = remoteConfig?.playerConfiguration?.ads?.preload ?? "none"
        tabbedMetadataView.setMetadata(type: .stateAndLogs, dataStr: "Preload is set to: \(preloadSetting)")
        if let log = log {
            playerLogs += "\n\(log)"
        }
        tabbedMetadataView.setMetadata(type: .stateAndLogs, dataStr: playerLogs)
    }

    private func setAdInfo() {
        theoplayer.ads.requestScheduledAds { (scheduledAds, _) in
            self.theoplayer.ads.requestCurrentAds { (currentAds, _) in
                if let scheduledAds = scheduledAds, scheduledAds.count > 0 {
                    var sa = "Scheduled Ads:\n"
                    for scheduledAd in scheduledAds {
                        sa += """
                            Resource URI: \(scheduledAd.resourceURI)
                            Offset: \(scheduledAd.adBreak.timeOffset)
                            Max duration: \(scheduledAd.adBreak.maxDuration)
                            Max remaining duration: \(scheduledAd.adBreak.maxRemainingDuration)

                        """
                    }
                    self.tabbedMetadataView.setMetadata(type: .ads, dataStr: sa, isAppending: false)
                } else {
                    self.tabbedMetadataView.setMetadata(type: .ads, dataStr: "No Scheduled Ads\n", isAppending: false)
                }

                if let currentAds = currentAds, currentAds.count > 0 {
                    var ca = "Current Ads:\n"
                    for currentAd in currentAds {
                        ca += "    Integration: \(currentAd.integration.rawValue)\n"
                        if let id = currentAd.id {
                            ca += "    ID: \(id)\n"
                        }
                        if let width = currentAd.width {
                            ca += "    Width: \(width)\n"
                        }
                        if let height = currentAd.height {
                            ca += "    Height: \(height)\n"
                        }
                        if let skipOffset = currentAd.skipOffset {
                            ca += "    Skip Offset: \(skipOffset)\n"
                        }
                        if let resourceURI = currentAd.resourceURI {
                            ca += "    Resource URI: \(resourceURI)\n"
                        }
                        if let adBreak = currentAd.adBreak {
                            ca += """
                                Offset: \(adBreak.timeOffset)
                                Max duration: \(adBreak.maxDuration)
                                Max remaining duration: \(adBreak.maxRemainingDuration)

                            """
                        }
                    }
                    self.tabbedMetadataView.setMetadata(type: .ads,
                                                        dataStr: ca)
                } else {
                    self.tabbedMetadataView.setMetadata(type: .ads,
                                                        dataStr: "No Current Ads")
                }
            }
        }
    }

    // MARK: - THEOplayer listener related functions and closures

    private func attachEventListeners() {
        // Listen to event and store references in dictionary
        listeners["play"] = theoplayer.addEventListener(type: PlayerEventTypes.PLAY, listener: onPlay)
        listeners["playing"] = theoplayer.addEventListener(type: PlayerEventTypes.PLAYING, listener: onPlaying)
        listeners["pause"] = theoplayer.addEventListener(type: PlayerEventTypes.PAUSE, listener: onPause)
        listeners["seeking"] = theoplayer.addEventListener(type: PlayerEventTypes.SEEKING, listener: onSeeking)
        listeners["seeked"] = theoplayer.addEventListener(type: PlayerEventTypes.SEEKED, listener: onSeeked)
        listeners["ended"] = theoplayer.addEventListener(type: PlayerEventTypes.ENDED, listener: onEnded)
        listeners["error"] = theoplayer.addEventListener(type: PlayerEventTypes.ERROR, listener: onError)

        // Add track listeners
        listeners["vAddTrack"] = theoplayer.videoTracks.addEventListener(type: VideoTrackListEventTypes.ADD_TRACK, listener: onTrackAdded)
        listeners["aAddTrack"] = theoplayer.audioTracks.addEventListener(type: AudioTrackListEventTypes.ADD_TRACK, listener: onTrackAdded)
        listeners["tAddTrack"] = theoplayer.textTracks.addEventListener(type: TextTrackListEventTypes.ADD_TRACK, listener: onTrackAdded)
        listeners["vChange"] = theoplayer.videoTracks.addEventListener(type: VideoTrackListEventTypes.CHANGE, listener: onTrackChange)
        listeners["aChange"] = theoplayer.audioTracks.addEventListener(type: AudioTrackListEventTypes.CHANGE, listener: onTrackChange)
        listeners["tChange"] = theoplayer.textTracks.addEventListener(type: TextTrackListEventTypes.CHANGE, listener: onTrackChange)
        listeners["vRemoveTrack"] = theoplayer.videoTracks.addEventListener(type: VideoTrackListEventTypes.REMOVE_TRACK, listener: onTrackRemove)
        listeners["aRemoveTrack"] = theoplayer.audioTracks.addEventListener(type: AudioTrackListEventTypes.REMOVE_TRACK, listener: onTrackRemove)
        listeners["tRemoveTrack"] = theoplayer.textTracks.addEventListener(type: TextTrackListEventTypes.REMOVE_TRACK, listener: onTrackRemove)

        // Add time listeners
        listeners["timeUpdate"] = theoplayer.addEventListener(type: PlayerEventTypes.TIME_UPDATE, listener: onTimeUpdated)

        // Add ads listeners
        listeners["adLoaded"] = theoplayer.ads.addEventListener(type: AdsEventTypes.AD_LOADED, listener: onAdLoaded)
        listeners["adBegin"] = theoplayer.ads.addEventListener(type: AdsEventTypes.AD_BEGIN, listener: onAdBegin)
        listeners["adEnd"] = theoplayer.ads.addEventListener(type: AdsEventTypes.AD_END, listener: onAdEnd)
        listeners["adBreakBegin"] = theoplayer.ads.addEventListener(type: AdsEventTypes.AD_BREAK_BEGIN, listener: onAdBreakBegin)
        listeners["adBreakEnd"] = theoplayer.ads.addEventListener(type: AdsEventTypes.AD_BREAK_END, listener: onAdBreakEnd)

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
        theoplayer.removeEventListener(type: PlayerEventTypes.SEEKING, listener: listeners["seeking"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.SEEKED, listener: listeners["seeked"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ENDED, listener: listeners["ended"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ERROR, listener: listeners["error"]!)

        // Remove track listeners
        theoplayer.videoTracks.removeEventListener(type: VideoTrackListEventTypes.ADD_TRACK, listener: listeners["vAddTrack"]!)
        theoplayer.audioTracks.removeEventListener(type: AudioTrackListEventTypes.ADD_TRACK, listener: listeners["aAddTrack"]!)
        theoplayer.textTracks.removeEventListener(type: TextTrackListEventTypes.ADD_TRACK, listener: listeners["tAddTrack"]!)
        theoplayer.videoTracks.removeEventListener(type: VideoTrackListEventTypes.CHANGE, listener: listeners["vChange"]!)
        theoplayer.audioTracks.removeEventListener(type: AudioTrackListEventTypes.CHANGE, listener: listeners["aChange"]!)
        theoplayer.textTracks.removeEventListener(type: TextTrackListEventTypes.CHANGE, listener: listeners["tChange"]!)
        theoplayer.videoTracks.removeEventListener(type: VideoTrackListEventTypes.REMOVE_TRACK, listener: listeners["vRemoveTrack"]!)
        theoplayer.audioTracks.removeEventListener(type: AudioTrackListEventTypes.REMOVE_TRACK, listener: listeners["aRemoveTrack"]!)
        theoplayer.textTracks.removeEventListener(type: TextTrackListEventTypes.REMOVE_TRACK, listener: listeners["tRemoveTrack"]!)

        // Remove time listeners
        theoplayer.removeEventListener(type: PlayerEventTypes.TIME_UPDATE, listener: listeners["timeUpdate"]!)

        // Remove ads listeners
        theoplayer.ads.removeEventListener(type: AdsEventTypes.AD_LOADED, listener: listeners["adLoaded"]!)
        theoplayer.ads.removeEventListener(type: AdsEventTypes.AD_BEGIN, listener: listeners["adBegin"]!)
        theoplayer.ads.removeEventListener(type: AdsEventTypes.AD_END, listener: listeners["adEnd"]!)
        theoplayer.ads.removeEventListener(type: AdsEventTypes.AD_BREAK_BEGIN, listener: listeners["adBreakBegin"]!)
        theoplayer.ads.removeEventListener(type: AdsEventTypes.AD_BREAK_END, listener: listeners["adBreakEnd"]!)

        // Remove chromecast listeners
        if let cast = theoplayer.cast, let _ = cast.chromecast  {
            theoplayer.removeEventListener(type: ChromecastEventTypes.STATE_CHANGE, listener: listeners["castStateChange"]!)
            theoplayer.removeEventListener(type: ChromecastEventTypes.ERROR, listener: listeners["castError"]!)
        }

        listeners.removeAll()
    }

    private func onPlay(event: PlayEvent) {
        os_log("PLAY event, currentTime: %f", event.currentTime)
        setStateAndLogInfo(log: "Event PLAY, currentTime=\(event.currentTime)")
    }

    private func onPlaying(event: PlayingEvent) {
        os_log("PLAYING event, currentTime: %f", event.currentTime)
        setStateAndLogInfo(log: "Event PLAYING, currentTime=\(event.currentTime)")
    }

    private func onPause(event: PauseEvent) {
        os_log("PAUSE event, currentTime: %f", event.currentTime)
        setStateAndLogInfo(log: "Event PAUSE, currentTime=\(event.currentTime)")
    }

    private func onSeeking(event: SeekingEvent) {
        os_log("SEEKING event, currentTime: %f", event.currentTime)
        setStateAndLogInfo(log: "Event SEEKING, currentTime=\(event.currentTime)")
    }

    private func onSeeked(event: SeekedEvent) {
        os_log("SEEKED event, currentTime: %f", event.currentTime)
        setStateAndLogInfo(log: "Event SEEKED, currentTime=\(event.currentTime)")
    }

    private func onEnded(event: EndedEvent) {
        os_log("ENDED event, currentTime: %f", event.currentTime)
        setStateAndLogInfo(log: "Event ENDED, currentTime=\(event.currentTime)")
    }

    private func onError(event: ErrorEvent) {
        os_log("ERROR event, error: %@", event.error)
        tabbedMetadataView.setMetadata(
            type: .stateAndLogs,
            dataStr: "Event ERROR, error: \(event.error)"
        )
    }

    private func onTimeUpdated(event: TimeUpdateEvent) {
        os_log("TIME_UPDATE event, currentTime: %f", event.currentTime)
        setTimeInfo()
    }

    private func onTrackAdded(event: AddTrackEvent) {
        os_log("ADD_TRACK event, kind: %@", event.track.kind)
        setTrackInfo()
        setStateAndLogInfo(log: "Event ADD_TRACK")
    }

    private func onTrackChange(event: TrackChangeEvent) {
        os_log("CHANGE event, kind: %@", event.track.kind)
        setTrackInfo()
        setStateAndLogInfo(log: "Event TRACK CHANGE")
    }

    private func onTrackRemove(event: RemoveTrackEvent) {
        os_log("TRACK_REMOVE event, kind: %@", event.track.kind)
        setStateAndLogInfo(log: "Event TRACK_REMOVE")
    }

    private func onAdLoaded(event: AdLoadedEvent) {
        os_log("AD_LOADED event, type: %@", event.type)
        setAdInfo()
        setStateAndLogInfo(log: "Event AD_LOADED")
    }

    private func onAdBegin(event: AdBeginEvent) {
        os_log("AD_BEGIN event, type: %@", event.type)
        setAdInfo()
        setStateAndLogInfo(log: "Event AD_BEGIN")
    }

    private func onAdEnd(event: AdEndEvent) {
        os_log("AD_END event, type: %@", event.type)
        setAdInfo()
        setStateAndLogInfo(log: "Event AD_END")
    }

    private func onAdBreakBegin(event: AdBreakBeginEvent) {
        os_log("AD_BREAK_BEGIN event, type: %@", event.type)
        setStateAndLogInfo(log: "Event AD_BREAK_BEGIN")
    }

    private func onAdBreakEnd(event: AdBreakEndEvent) {
        os_log("AD_BREAK_END event, type: %@", event.type)
        setStateAndLogInfo(log: "Event AD_BREAK_END")
    }

    private func onCastStateChange(event: StateChangeEvent) {
        os_log("Chromecast STATE_CHANGE event, state: %@", event.state.rawValue)
    }

    private func onCastError(event: CastErrorEvent) {
        os_log("Chromecast ERROR event, error: %@", event.error.errorCode.rawValue)
    }
}
