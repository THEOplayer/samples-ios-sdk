//
//  PlayerViewController.swift
//  Metadata_Handling
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

    private var playerViewContainer: UIView!
    private var playerViewTitle: UILabel!
    private var metadataContainer: UIView!
    private var metadataTitle: UILabel!
    private var metadataTextScrollView: UIScrollView!
    private var metadataTextView: UITextView!

    // THEOplayer object
    private var theoplayer: THEOplayer!

    // Array of portrait and landscape speccific constraints
    private var portraitConstaints: [NSLayoutConstraint] = [NSLayoutConstraint]()
    private var landscapeConstaints: [NSLayoutConstraint] = [NSLayoutConstraint]()

    // Dictionary of player event listeners
    private var listeners: [String: EventListener] = [:]
    // Keeping reference to all the listened Track objects
    private var listenedTracks: [Track] = [Track]()

    private var source: SourceDescription {
        // Declare a TypedSource object with a stream URL and its type
        let typedSource = TypedSource(
            src: stream.url,
            type: stream.mimeType,
            /* Enable stream specific date range metsdata based on steam type.
                Date range metsdata can also be enabled globally by setting
                the hlsDateRange flag in THEOplayerConfiguration
             */
            hlsDateRange: stream.type == .dateRange
        )

        // Returns a computed SourceDescription object
        return SourceDescription(source: typedSource)
    }

    // ScrollView observation and flag for auto scroll support
    private var scrollViewObservation: NSKeyValueObservation!
    private var isScrollViewDragging: Bool = false

    // Constant title string above the metadata text view
    private let metadataTitleText = "Metadata content"

    // Stream object to be played
    private let stream: Stream

    // MARK: - View controller life cycle

    init(stream: Stream) {
        // Initialise property
        self.stream = stream
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func deInit() {
        // Free UIScrollView content size obversations
        scrollViewObservation.invalidate()
        scrollViewObservation = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupPlayerViewContainer()
        setupPlayerViewTitle()
        setupPlayerView()
        setupMetadataContainer()
        setupMetadataTitle()
        setupScrollableTextView()
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
        // Setup margins around the view
        view.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    private func setupPlayerViewContainer() {
        playerViewContainer = THEOComponent.view()

        view.addSubview(playerViewContainer)

        let layoutMargins = view.layoutMarginsGuide
        playerViewContainer.leadingAnchor.constraint(equalTo: layoutMargins.leadingAnchor).isActive = true

        // Appending portrait constraints
        portraitConstaints += [
            playerViewContainer.topAnchor.constraint(equalTo: layoutMargins.topAnchor),
            playerViewContainer.widthAnchor.constraint(equalTo: layoutMargins.widthAnchor)
        ]

        // Appending landscape constraints
        landscapeConstaints += [
            playerViewContainer.centerYAnchor.constraint(equalTo: layoutMargins.centerYAnchor),
            playerViewContainer.widthAnchor.constraint(equalTo: layoutMargins.widthAnchor, multiplier: 0.5, constant: -10)
        ]
    }

    private func setupPlayerViewTitle() {
        playerViewTitle = THEOComponent.label(text: stream.title, isTitle: true)
        playerViewTitle.textColor = .theoWhite

        playerViewContainer.addSubview(playerViewTitle)
        playerViewTitle.leadingAnchor.constraint(equalTo: playerViewContainer.leadingAnchor, constant: 10.0).isActive = true
        playerViewTitle.topAnchor.constraint(equalTo: playerViewContainer.topAnchor).isActive = true
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
        playerViewContainer.addSubview(theoplayerView)

        // Set theoplayerView aspect ratio to 16 : 9 using the width anchor of vStackView
        theoplayerView.heightAnchor.constraint(equalTo: theoplayerView.widthAnchor, multiplier: 9 / 16).isActive = true
        theoplayerView.widthAnchor.constraint(equalTo: playerViewContainer.widthAnchor).isActive = true
        theoplayerView.leadingAnchor.constraint(equalTo: playerViewContainer.leadingAnchor).isActive = true
        theoplayerView.topAnchor.constraint(equalTo: playerViewTitle.bottomAnchor, constant: 10).isActive = true
        theoplayerView.bottomAnchor.constraint(equalTo: playerViewContainer.bottomAnchor).isActive = true
    }

    private func setupMetadataContainer() {
        metadataContainer = THEOComponent.view()

        view.addSubview(metadataContainer)
        metadataContainer.widthAnchor.constraint(equalTo: theoplayerView.widthAnchor).isActive = true

        let layoutMargins = view.layoutMarginsGuide
        metadataContainer.bottomAnchor.constraint(equalTo: layoutMargins.bottomAnchor).isActive = true

        // Appending portrait constraints
        portraitConstaints += [
            metadataContainer.topAnchor.constraint(equalTo: theoplayerView.bottomAnchor, constant: 20),
            metadataContainer.leadingAnchor.constraint(equalTo: layoutMargins.leadingAnchor)
        ]

        // Appending landscape constraints
        landscapeConstaints += [
            metadataContainer.topAnchor.constraint(equalTo: layoutMargins.topAnchor),
            metadataContainer.leadingAnchor.constraint(equalTo: theoplayerView.trailingAnchor, constant: 20)
        ]
    }

    private func setupMetadataTitle() {
        metadataTitle = THEOComponent.label(text: metadataTitleText, isTitle: true)
        metadataTitle.textColor = .theoWhite

        metadataContainer.addSubview(metadataTitle)
        metadataTitle.leadingAnchor.constraint(equalTo: metadataContainer.leadingAnchor, constant: 10.0).isActive = true
        metadataTitle.topAnchor.constraint(equalTo: metadataContainer.topAnchor).isActive = true
    }

    private func setupScrollableTextView() {
        (metadataTextScrollView, metadataTextView) = THEOComponent.scrollableTextView(isReadOnly: true)
        metadataTextScrollView.delegate = self

        // Observe changes on scrollview contentSize and auto scroll
        scrollViewObservation = metadataTextScrollView.observe(\.contentSize) { scrollView, change in
            // Only auto scroll when the metadata scrollView content is scrollable and is not dragged by user
            if scrollView.isUserInteractionEnabled &&
                !self.isScrollViewDragging &&
                self.metadataTextScrollView.contentSize.height >= self.metadataTextScrollView.bounds.size.height {
                scrollView.flashScrollIndicators()
                let bottomOffset = CGPoint(x: 0, y: self.metadataTextScrollView.contentSize.height - self.metadataTextScrollView.bounds.size.height)
                self.metadataTextScrollView.setContentOffset(bottomOffset, animated: true)
            }
        }

        metadataContainer.addSubview(metadataTextScrollView)
        metadataTextScrollView.leadingAnchor.constraint(equalTo: metadataContainer.leadingAnchor).isActive = true
        metadataTextScrollView.trailingAnchor.constraint(equalTo: metadataContainer.trailingAnchor).isActive = true
        metadataTextScrollView.topAnchor.constraint(equalTo: metadataTitle.bottomAnchor, constant: 10).isActive = true
        metadataTextScrollView.bottomAnchor.constraint(equalTo: metadataContainer.bottomAnchor).isActive = true
    }

    // MARK: - THEOplayer setup and unload

    private func setupTheoplayer() {
        // Instantiate player object
        theoplayer = THEOplayer()

        // dateRange metadata event is not sent consistently when autoplay flag is set
        theoplayer.autoplay = stream.type != .dateRange

        // Add the player to playerView's view hierarchy
        theoplayer.addAsSubview(of: theoplayerView)

        attachEventListeners()
    }

    private func unloadTheoplayer() {
        // Removing listeners for tracks in listenedTracks (LIFO)
        for index in (0..<listenedTracks.count).reversed() {
            // Track in listenedTracks will be remove in removeTrackCueEventListeners
            removeTrackCueEventListeners(track: listenedTracks[index])
        }
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

    private func processId3Cue(cue: Id3Cue) {
        if let contentDict = cue.contentDictionary {
            if let text = contentDict["text"] {
                os_log("ID3 metadata: %@", text)
                metadataTextView.text += "\(text)\n"
            } else {
                os_log("contentDictionary has no 'text' for cue with ID: %@", cue.id)
            }
        } else {
            os_log("contentDictionary is nil for cue with ID: %@", cue.id)
        }
    }

    private func processDataRangeCue(cue: DateRangeCue) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let startDate = "Start Date: \(formatter.string(from: cue.startDate))\n"

        var endDate = "End Date: N/A\n"
        if let date = cue.endDate {
            endDate = "End Date: \(formatter.string(from: date))\n"
        }

        var durationStr = "Duration: N/A\n"
        if let duration = cue.duration {
            durationStr = "Duration: \(duration) seconds\n"
        }

        var scte35Cmd = "SCTE35 Cmd: N/A\n"
        if let data = cue.scte35Cmd {
            scte35Cmd = "SCTE35 Cmd: \(data.base64EncodedString())\n"
        }

        var scte35In = "SCTE35 In: N/A\n"
        if let data = cue.scte35In {
            scte35In = "SCTE35 In: \(data.base64EncodedString())\n"
        }

        var scte35Out = "SCTE35 Out: N/A\n"
        if let data = cue.scte35Out {
            scte35Out = "SCTE35 Out: \(data.base64EncodedString())\n"
        }

        let contentString = "\(startDate)\(endDate)\(durationStr)\(scte35Cmd)\(scte35In)\(scte35Out)"
        os_log("Date range metadata: %@", contentString)
        metadataTextView.text += "\(contentString)\n"
    }

    // MARK: - THEOplayer listener related functions and closures

    private func attachEventListeners() {
        // Listen to event and store references in dictionary
        listeners["play"] = theoplayer.addEventListener(type: PlayerEventTypes.PLAY, listener: onPlay)
        listeners["playing"] = theoplayer.addEventListener(type: PlayerEventTypes.PLAYING, listener: onPlaying)
        listeners["pause"] = theoplayer.addEventListener(type: PlayerEventTypes.PAUSE, listener: onPause)
        listeners["ended"] = theoplayer.addEventListener(type: PlayerEventTypes.ENDED, listener: onEnded)
        listeners["error"] = theoplayer.addEventListener(type: PlayerEventTypes.ERROR, listener: onError)

        // Add stream type speicifc listeners
        if stream.type == .id3 || stream.type == .dateRange {
            listeners["addTrack"] = theoplayer.textTracks.addEventListener(type: TextTrackListEventTypes.ADD_TRACK, listener: onTrackAdded)
            listeners["removeTrack"] = theoplayer.textTracks.addEventListener(type: TextTrackListEventTypes.REMOVE_TRACK, listener: onTrackRemoved)
            listeners["changeTrack"] = theoplayer.textTracks.addEventListener(type: TextTrackListEventTypes.CHANGE, listener: onTrackChanged)
        }
        if stream.type == .programDateTime {
            listeners["timeUpdate"] = theoplayer.addEventListener(type: PlayerEventTypes.TIME_UPDATE, listener: onTimeUpdated)
        }
    }

    private func removeEventListeners() {
        // Remove event listenrs
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAY, listener: listeners["play"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PLAYING, listener: listeners["playing"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.PAUSE, listener: listeners["pause"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ENDED, listener: listeners["ended"]!)
        theoplayer.removeEventListener(type: PlayerEventTypes.ERROR, listener: listeners["error"]!)

        // Remove stream type speicifc listeners
        if stream.type == .id3 || stream.type == .dateRange {
            theoplayer.textTracks.removeEventListener(type: TextTrackListEventTypes.ADD_TRACK, listener: listeners["addTrack"]!)
            theoplayer.textTracks.removeEventListener(type: TextTrackListEventTypes.REMOVE_TRACK, listener: listeners["removeTrack"]!)
            theoplayer.textTracks.removeEventListener(type: TextTrackListEventTypes.CHANGE, listener: listeners["changeTrack"]!)
        }
        if stream.type == .programDateTime {
            theoplayer.removeEventListener(type: PlayerEventTypes.TIME_UPDATE, listener: listeners["timeUpdate"]!)
        }

        listeners.removeAll()
    }

    private func attachTrackCueEventListeners(track: Track) {
        // Add Track specific listeners and retain reference for removal
        if listenedTracks.filter({ $0.uid == track.uid }).count == 0 {
            listeners["addCue\(track.uid)"] = track.addEventListener(type: TextTrackEventTypes.ADD_CUE, listener: onCueAdded)
            listeners["removeCue\(track.uid)"] = track.addEventListener(type: TextTrackEventTypes.REMOVE_CUE, listener: onCueRemoved)
            listeners["cueChange\(track.uid)"] = track.addEventListener(type: TextTrackEventTypes.CUE_CHANGE, listener: onCueChanged)
            listeners["enterCue\(track.uid)"] = track.addEventListener(type: TextTrackEventTypes.ENTER_CUE, listener: onCueEntered)
            listeners["exitCue\(track.uid)"] = track.addEventListener(type: TextTrackEventTypes.EXIT_CUE, listener: onCueExited)
            listenedTracks.append(track)
        }
    }

    private func removeTrackCueEventListeners(track: Track) {
        track.removeEventListener(type: TextTrackEventTypes.ADD_CUE, listener: listeners["addCue\(track.uid)"]!)
        _ = listeners.removeValue(forKey: "addCue\(track.uid)")
        track.removeEventListener(type: TextTrackEventTypes.REMOVE_CUE, listener: listeners["removeCue\(track.uid)"]!)
        _ = listeners.removeValue(forKey: "removeCue\(track.uid)")
        track.removeEventListener(type: TextTrackEventTypes.CUE_CHANGE, listener: listeners["cueChange\(track.uid)"]!)
        _ = listeners.removeValue(forKey: "cueChange\(track.uid)")
        track.removeEventListener(type: TextTrackEventTypes.ENTER_CUE, listener: listeners["enterCue\(track.uid)"]!)
        _ = listeners.removeValue(forKey: "enterCue\(track.uid)")
        track.removeEventListener(type: TextTrackEventTypes.EXIT_CUE, listener: listeners["exitCue\(track.uid)"]!)
        _ = listeners.removeValue(forKey: "exitCue\(track.uid)")

        // Match Track by uid and remove it from listenedTracks
        if let index = listenedTracks.firstIndex(where: {$0.uid == track.uid}) {
            listenedTracks.remove(at: index)
        }
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

    private func onTimeUpdated(event: TimeUpdateEvent) {
        os_log("TIME_UPDATE event, currentTime: %f", event.currentTime)

        theoplayer.requestCurrentProgramDateTime { (date, error) in
            if let date = date {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                os_log("TIME_UPDATE event, content: %@", formatter.string(from: date))
                self.metadataTextView.text += "\(formatter.string(from: date))\n"
            } else if let error = error {
                os_log("requestCurrentProgramDateTime, error: %@", error.localizedDescription)
            } else {
                os_log("Both date and error are nil")
            }
        }
    }

    private func onTrackAdded(event: AddTrackEvent) {
        os_log("ADD_TRACK event, kind: %@", event.track.kind)

        // Filter for ID3 and dateRange TextTrack and attach listeners
        if let textTrack = event.track as? TextTrack {
            if (stream.type == .id3 && textTrack.type == "id3") ||
                (stream.type == .dateRange && textTrack.type == "daterange") {
                attachTrackCueEventListeners(track: textTrack)
            }
        }
    }

    private func onTrackRemoved(event: RemoveTrackEvent) {
        os_log("REMOVE_Track event, kind: %@", event.track.kind)

        removeTrackCueEventListeners(track: event.track)
    }

    private func onTrackChanged(event: TrackChangeEvent) {
        os_log("CHANGE event, kind: %@", event.track.kind)
    }

    private func onCueAdded(event: AddCueEvent) {
        os_log("ADD_CUE event, id: %@", event.cue.id)

        // Process dataRange metadata here
        if stream.type == .dateRange, let dateRangeCue = event.cue as? DateRangeCue {
            processDataRangeCue(cue: dateRangeCue)
        }
    }

    private func onCueRemoved(event: RemoveCueEvent) {
        os_log("REMOVE_CUE event, id: %@", event.cue.id)
    }

    private func onCueChanged(event: CueChangeEvent) {
        os_log("CUE_CHANGE event, type: %@, track uid: %d", event.type, event.track.uid)
    }

    private func onCueEntered(event: EnterCueEvent) {
        os_log("ENTER_CUE event, id: %@", event.cue.id)
    }

    private func onCueExited(event: ExitCueEvent) {
        os_log("EXIT_CUE event, id: %@", event.cue.id)

        // ID3 Cue is in force on exit, process it here
        if let id3Cue = event.cue as? Id3Cue {
            self.processId3Cue(cue: id3Cue)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension PlayerViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrollViewDragging = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isScrollViewDragging = false
    }
}
