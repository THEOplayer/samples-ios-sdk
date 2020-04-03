# THEOplayer How To's - Google Cast Integration

This guide is going to cover the steps to integrate Google Cast to [THEO Basic Playback].

The complete implementation can be found in [PlayerViewController.swift] with inline comments. The following sub-sections only highlight the key points.

## Table of Contents

* [Setup Google Cast Framework]
  * [Cocoapods Setup]
  * [Manual Setup]
  * [Access WiFi Information]
* [GCKCastContext]
* [Cast Strategy]
* [Cast Button]
* [Cast Metadata]
* [Custom Cast Source]
* [Cast Event Listeners]
* [Summary]

## Setup Google Cast Framework

Please note the warnings state in [Google Cast iOS Sender]:

> **`iOS 13 Warning`**: Apple permissions changes to iOS 13 and Xcode 11 have impacted the Google Cast iOS SDK in a number of ways. Please see the [iOS 13 Changes] document to see how your app will be impacted.

and

> **`iOS 12 Warning`**: If developing using Xcode 10 and targeting iOS devices running iOS 12 or higher, the "Access WiFi Information" capability is required in order to discover and connect to Cast devices.

[Google Cast iOS Sender] offers 2 ways to install Google Cast Framework:

### Cocoapods Setup

THEOplayer only supports Google Cast Framework installed by Cocoapods until version `4.3.0`, example `Podfile` is listed below. Please visit [Cocoapods] to find out how to setup Cocoapods for Xcode project.

```bash
# Comment the next line if you are not using Swift and do not want to use dynamic frameworks
use_frameworks!

# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

def target_pods
    pod 'google-cast-sdk'
end

target'YourProjectTarget' do
    # Select one of the chromecast versions
    pod 'google-cast-sdk', '4.3.0'
end
```

### Manual Setup

Download the Dynamic Google Cast Framework from [Google Cast iOS Sender] and follow the very detailed instructions in the `Manual Setup` section. Note the following when choosing between framework with or without [Guest Mode].

> Libraries without [guest mode] have been provided for situations where your app does not require the feature or you do not wish to require Bluetooth® permissions, which have been introduced in iOS 13. Please see the [iOS 13 Changes] document for more information.

At the time of writing, the latest Google Cast Framework version is `4.4.7` and the reference app setup Google Cast Framework as per the `Manual Setup` instructions.

### Access WiFi Information

As stated in [Google Cast iOS Sender], the **`Access WiFi Information`** capability is required. Note that only enrolled Apple Developer account can enable this capability, please visit [Apple Developer Program] for more information.

## GCKCastContext

To enable Google Cast on iOS the GCKCastContext shared instance shall be set.
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

Create a `UIBarButtonItem` button and set it as the right button on the navigation bar. The button handler is using the `Chromecast` object to join/leave chrome cast session depending on the `casting` flag.

```swift
class PlayerViewController: UIViewController {

    ...

    private var chromeCastButton: UIBarButtonItem!

    ...

    override func viewDidLoad() {

        ...

        setupchromeCast()

        ...
    }

    private func setupchromeCast() {
        ...

        chromeCastButton = UIBarButtonItem(image: UIImage(named: "ic_cast_black_24dp"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(onChromecast))
        chromeCastButton.tintColor = .theoWhite
        chromeCastButton.isEnabled = false

        navigationItem.rightBarButtonItem = chromeCastButton
    }

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

The code snippet below demonstrates how to setup a different stream and use the `Chromecast` object to cast the stream to the Cast Receiver device.

```swift
class PlayerViewController: UIViewController {

    ...

     override func viewWillAppear(_ animated: Bool) {

        ...

        if var chromecast = theoplayer.cast?.chromecast {
            chromecast.source = SourceDescription(source:
                TypedSource(
                    src: videoUrl,
                    type: mimeType
                )
            )
        }

        ...
    }

...
}
```

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
        os_log("Chromecast STATE_CHANGE event, state: %@", event.state.rawValue)

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
```

## Summary

This guide covered how to integrate Google Cast integration and demonstrated different ways to use Google Cast through THEOplayer APIs. To find out more about Google Cast, please visit [Google Cast iOS Sender].

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[Setup Google Cast Framework]: #Setup-Google-Cast-Framework
[Cocoapods Setup]: #Cocoapods-Setup
[Manual Setup]: #Manual-Setup
[Access WiFi Information]: #Access-WiFi-Information
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
[Guest Mode]: https://developers.google.com/cast/docs/guest_mode
[iOS 13 Changes]: https://developers.google.com/cast/docs/ios_sender/ios13_changes
[GCKCastOptions]: https://developers.google.com/cast/docs/reference/ios/interface_g_c_k_cast_options
[Cocoapods]: https://cocoapods.org/
[Apple Developer Program]: https://developer.apple.com/support/compare-memberships/
[THEO Docs]: https://docs.portal.theoplayer.com/

[//]: # (Project files reference)
[PlayerViewController.swift]: ../../Google_Cast/PlayerViewController.swift
