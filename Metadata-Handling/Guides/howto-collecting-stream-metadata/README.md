# THEOplayer How To's - Collecting Stream Metadata

This guide is going to show how to collect various type of metadata embedded in stream playing by THEOplayer.

## Table of Contents

* [Overview]
* [HLS with ID3 metadata]
* [HLS with PROGRAM-DATE-TIME]
* [HLS with DATERANGE]
* [Summary]

## Overview

An overview of changes made to [THEO Basic Playback] are highlighted below, this helps to clarify the logic and data flow behind this reference app.

* `PlayerViewController` as the Navigation Controller's root view controller has been replaced by `MetadataViewController`.
* `MetadataViewController` has a `UITableVIew` that presents `Stream` objects as `MetadataTableViewCell`.
* `Stream` object defines the URL of the stream and type of metadata it carries. It is passed directly to `PlayerViewController` as initialisation parameter when user tap on a `MetadataTableViewCell`.
* `SourceDescription` will be computed using the given `Stream` object.
* `metadataTextView` is declared as a `UITextView` object in `PlayerViewController` and can be used to display metadata on the screen. Metadata collected in the following subsections will simply write to it as follows:

```swift
    metadataTextView.text = "New Metadata"
    metadataTextView.text += "\nmore Metadata"
```

* `PlayerViewController` instance will be discarded when user navigate back to `MetadataViewController` which means there is no need to clean `metadataTextView` when user switch to different HLS stream.

Checkout [PlayerViewController.swift] and [MetadataViewController.swift] to find out more.

## HLS with ID3 metadata

THEOPlayer has full support for ID3 Timed Metadata in HTTP Live Streaming. This allows user to synchronize external metadata with the content which is being played. Timed metadata in content can be used by clients as cuepoints for information display or to invoke time-aligned actions and so on. This information can be made available in HLS as ID3 tags.

To collect id3 metadata in HLS, add listener to `TextTrackListEventTypes.ADD_TRACK` on THEOplayer `TextTrackList` object and filter for `TextTrack` object with type equals `"id3"`.

Add `TextTrackEventTypes.EXIT_CUE` listener to the matched `TextTrack` object to collect the `ExitCueEvent` event.

```swift
class PlayerViewController: UIViewController {

    ...

    private func attachEventListeners() {

        ...

        listeners["addTrack"] = theoplayer.textTracks.addEventListener(type: TextTrackListEventTypes.ADD_TRACK, listener: onTrackAdded)

        ...
    }

    private func onTrackAdded(event: AddTrackEvent) {
        os_log("ADD_TRACK event, kind: %@", event.track.kind)

        if let textTrack = event.track as? TextTrack {
            if (stream.type == .id3 && textTrack.type == "id3")  {
                attachTrackCueEventListeners(track: textTrack)
            }
        }
    }

    private func attachTrackCueEventListeners(track: Track) {

        ...

        listeners["exitCue\(track.uid)"] = track.addEventListener(type: TextTrackEventTypes.EXIT_CUE, listener: onCueExited)

        ...
    }

    ...
}
```

Cast the `ExitCueEvent` as `Id3Cue` to ensure it is a id3 cue and then access the desire metadata via the `contentDictionary` dictionary. For the purpose of demonstration, only the `text` field will be appended to `metadataTextView`.

```swift
class PlayerViewController: UIViewController {

    ...

    private func onCueExited(event: ExitCueEvent) {
        os_log("EXIT_CUE event, id: %@", event.cue.id)

        if let id3Cue = event.cue as? Id3Cue {
            self.processId3Cue(cue: id3Cue)
        }
    }

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

    ....
}
```

## HLS with PROGRAM-DATE-TIME

THEOplayer has support for associating media segments with an absolute date and time. This can be useful when user wants to synchronise video playback with displaying other relevant information about the video stream.

THEOplayer enables this feature by making use of the `EXT-X-PROGRAM-DATE-TIME` information that gets embedded in the HLS manifest file.

To collect program date time metadata in HLS, add listener to the `PlayerEventTypes.TIME_UPDATE` event for time update and then use the `requestCurrentProgramDateTime()` API when the event is fired. Program date time will be returned as a `Date` object which will then formatted and appended to `metadataTextView`.

```swift
class PlayerViewController: UIViewController {

    ...

    private func attachEventListeners() {

        ...

        listeners["timeUpdate"] = theoplayer.addEventListener(type: PlayerEventTypes.TIME_UPDATE, listener: onTimeUpdated)

        ...
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

    ...
}
```

## HLS with DATERANGE

HLS supports manifests which contain the `EXT-X-DATERANGE` tag. This is used to define date range metadata in a media playlist. A possible use case is defining timed metadata for interstitial regions such as advertisements, but can be used to define any timed metadata needed by the user.

To collect date range in HLS, add listener to `TextTrackListEventTypes.ADD_TRACK` on THEOplayer `TextTrackList` object and filter for `TextTrack` object with type equals `"daterange"`.

Add `TextTrackEventTypes.ADD_CUE` listener to the matched `TextTrack` object to collect the `AddCueEvent` event.

```swift
class PlayerViewController: UIViewController {

    ...

    private func attachEventListeners() {

        ...

        listeners["addTrack"] = theoplayer.textTracks.addEventListener(type: TextTrackListEventTypes.ADD_TRACK, listener: onTrackAdded)

        ...
    }

    private func onTrackAdded(event: AddTrackEvent) {
        os_log("ADD_TRACK event, kind: %@", event.track.kind)

        if let textTrack = event.track as? TextTrack {
            if (stream.type == .dateRange && textTrack.type == "daterange")  {
               attachTrackCueEventListeners(track: textTrack)
            }
        }
    }

    private func attachTrackCueEventListeners(track: Track) {

        ...

        listeners["addCue\(track.uid)"] = track.addEventListener(type: TextTrackEventTypes.ADD_CUE, listener: onCueAdded)

        ...
    }

    ...
}
```

Cast the `AddCueEvent` as `DateRangeCue` to ensure it is a datarange cue and then check and append its properties to `metadataTextView`.

```swift
class PlayerViewController: UIViewController {

    ...

    private func onCueAdded(event: AddCueEvent) {
        os_log("ADD_CUE event, id: %@", event.cue.id)

        if stream.type == .dateRange, let dateRangeCue = event.cue as? DateRangeCue {
            processDataRangeCue(cue: dateRangeCue)
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
    ....
}
```

## Summary

This guided gave an overview on how the reference app work and demonstrated how to collect `ID3`, `PROGRAM-DATE-TIME` and `DATARANGE` metadata from HLS stream.

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[Overview]: #Overview
[HLS with ID3 metadata]: #-HLS-with-ID3-metadata
[HLS with PROGRAM-DATE-TIME]: #HLS-with-PROGRAM-DATE-TIME
[HLS with DATERANGE]: #HLS-with-DATERANGE
[Summary]: #Summary

[//]: # (Links and Guides reference)
[THEO Basic Playback]: ../Basic-Playback
[THEO Docs]: https://docs.portal.theoplayer.com/

[//]: # (Project files reference)
[PlayerViewController.swift]: ../../Metadata_Handling/PlayerViewController.swift
[MetadataViewController.swift]: ../../Metadata_Handling/MetadataViewController.swift
