# THEOplayer How To's - Google Cast Integration

This guide is going to cover the steps to integrate Google Cast to [THEO Basic Playback].

The complete implementation can be found in [PlayerViewController.swift] with inline comments. The following sub-sections only highlight the key points.

## Table of Contents

* [Setup Google Cast Framework]
* [GCKCastContext]
* [Cast Strategy]
* [Cast Button]
* [Cast Metadata]
* [Custom Cast Source]
* [Cast Event Listeners]
* [Summary]

## Setup Google Cast Framework

Before starting, please note the warnings in [Google Cast iOS Sender] regarding specific iOS versions.

[Google Cast iOS Sender] offers 2 ways to install Google Cast Framework. Please refer to the [How To Guide](https://docs.theoplayer.com/how-to-guides/03-cast/01-chromecast/06-enable-chromecast-on-the-sender.md#ios-sdk) on our website to learn how to set up the Cast framework.

## GCKCastContext

To enable Google Cast on iOS the `GCKCastContext` shared instance shall be set.
There are 2 ways to achieve this:

Instantiate [GCKCastOptions] with a `receiverApplicationID` and set it directly to `GCKCastContext`.

```swift
import GoogleCast

let options = GCKCastOptions(receiverApplicationID: "realAppID")
GCKCastContext.setSharedInstanceWith(options)
```

Or use default cast option provided by THEOplayer SDK.

```swift
THEOplayerCastHelper.setGCKCastContextSharedInstanceWithDefaultCastOptions()
```

## Cast Strategy

THEOplayer supports Google Cast session takeover. This means that when the user has selected a cast device and it is casting, a new video will automatically take over the existing session. In this manner, the user is not prompted for a cast device again so the viewing experience is faster and smoother.

Three types of behavior are defined:

* **`auto`** - when a cast session already exists, the player will automatically start casting when the play button is clicked. It is possible to start a session by clicking the cast button or using the global API.
* **`manual`** - when a cast session exists the player will NOT automatically start casting. However, when the cast button is clicked and a session exists, the existing session is used and the user is not prompted with a dialog.
* **`disabled`** - the player is not affected by Google Cast.

Cast Strategy can be configured via the `cast` parameter of `THEOplayerConfiguration` as follows:

```swift
class PlayerViewController: UIViewController {

    ...

    private func setupTheoplayer() {
        let playerConfig =  THEOplayerConfiguration(cast: CastConfiguration(strategy: .auto))
        theoplayer = THEOplayer(configuration: playerConfig)

        ...
    }

    ...
}
```

## Cast Button

This section describes how to add a native iOS button outside THEOplayer UI to start/leave chrome cast session. It can also be used to indicate the current cast status by listening to the `ChromecastEventTypes.STATE_CHANGE` event, see [Cast Event Listeners] for more detail.

Create a `GCKUICastButton` button and set it as the right button on the navigation bar. The button handler is using the `Chromecast` object to join/leave chrome cast session depending on the `casting` flag.

```swift
class PlayerViewController: UIViewController {

    ...

    private var chromeCastButton: GCKUICastButton?

    ...

    override func viewDidLoad() {

        ...

        setupchromeCast()

        ...
    }

    private func setupchromeCast() {
        ...

        self.chromeCastButton = GCKUICastButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(24), height: CGFloat(24)))
        
        self.chromeCastButton!.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.chromeCastButton!)
        
        self.chromeCastButton?.delegate = self // native button
    }

    @objc private func onChromecast() {
        if let cast = theoplayer.cast, let chromecast = cast.chromecast {
            if chromecast.casting {
                chromecast.stop()
            } else {
                chromecast.start()
            }
        } else {
            os_log("Chromecast module is not available in THEOplayer SDK.")
        }
    }

    ...
}
```

## Cast Metadata

To pass metadata to chrome cast receiver, instantiate a `ChromecastMetadataDescription` object with the metadata and pass it to `SourceDescription` through the `metadata` parameter.

```swift
class PlayerViewController: UIViewController {

    ...

    private var source: SourceDescription {
        ...

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

        return SourceDescription(source: typedSource, poster: posterUrl, metadata: chromecastMetadataDescription)
    }

    ...
}
```

## Custom Cast Source

Please refer to the [How To Guide](https://docs.theoplayer.com/how-to-guides/03-cast/01-chromecast/03-how-to-configure-to-a-different-stream.md#ios-sdk) on our website to learn how to do this.

## Cast Event Listeners

The code snippet demonstrates how to add and remove listeners to the chromecast `STATE_CHANGE` and `ERROR` events. See `THEOplayer iOS SDK` documentation for more information.

```swift
class PlayerViewController: UIViewController {

    ...

    private func attachEventListeners() {

        ...

        if let cast = theoplayer.cast, let chromecast = cast.chromecast {
            listeners["castStateChange"] = chromecast.addEventListener(type: ChromecastEventTypes.STATE_CHANGE, listener: onCastStateChange)
            listeners["castError"] = chromecast.addEventListener(type: ChromecastEventTypes.ERROR, listener: onCastError)
        }
    }

    private func removeEventListeners() {

        ...

        if let cast = theoplayer.cast, let _ = cast.chromecast  {
            theoplayer.removeEventListener(type: ChromecastEventTypes.STATE_CHANGE, listener: listeners["castStateChange"]!)
            theoplayer.removeEventListener(type: ChromecastEventTypes.ERROR, listener: listeners["castError"]!)
        }

        ...
    }

    ...

    private func onCastStateChange(event: StateChangeEvent) {
        os_log("Chromecast STATE_CHANGE event, state: %@", event.state._rawValue)
        
        if event.state != .unavailable {
            chromeCastButton?.isEnabled = true
        } else {
            chromeCastButton?.isEnabled = false
        }
    }

    private func onCastError(event: CastErrorEvent) {
        os_log("Chromecast ERROR event, error: %@", event.error.errorCode.rawValue)
    }
}
```

## Summary

This guide covered how to integrate Google Cast integration and demonstrated different ways to use Google Cast through THEOplayer APIs. To find out more about Google Cast, please visit [Google Cast iOS Sender].

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[Setup Google Cast Framework]: #Setup-Google-Cast-Framework
[GCKCastContext]: #GCKCastContext
[Cast Strategy]: #Cast-Strategy
[Cast Button]: #Cast-Button
[Cast Metadata]: #Cast-Metadata
[Custom Cast Source]: #Custom-Cast-Source
[Cast Event Listeners]: #Cast-Event-Listeners
[Summary]: #Summary

[//]: # (Links and Guides reference)
[THEO Basic Playback]: ../../Basic-Playback
[Google Cast iOS Sender]: https://developers.google.com/cast/docs/ios_sender
[GCKCastOptions]: https://developers.google.com/cast/docs/reference/ios/interface_g_c_k_cast_options
[THEO Docs]: https://docs.theoplayer.com/

[//]: # (Project files reference)
[PlayerViewController.swift]: ../../Google_Cast/PlayerViewController.swift
