# THEOplayer How To's - THEOplayer iOS SDK Integration

This guide is going to cover the steps to integrate **`THEOplayer SDK`** to an reference application project and playback a HLS stream. Please checkout the [THEOplayer How To's - Setup Reference Application] guide for detail on how to setup the reference application project.

## Table of Content

* [Import THEOplayer SDK]
* [Implementation]
  * [Create THEOplayer Object and Setup Player View]
  * [Register THEOplayer Event Listeners]
  * [Unload THEOplayer]
  * [Create HLS Source and Trigger Playback]
* [Summary]

## Import THEOplayer SDK

A typical **`THEOplayer SDK`** contains the THEOplayer doc in a zip file and the framework itself:

!["THEOplayer SDK Content"][01]

Recent version of the THEOplayer SDK offer a `THEOplayerSDK.framework` and `THEOplayerSDK.xcframework` file.
You should try to use `THEOplayerSDK.xcframework` whenever possible.

Drag and drop **`THEOplayer SDK`** file from **`Finder`** as shown in the screenshot below:

!["Drag And Drop THEOplayer SDK"][02]

Click on `Copy items if needed` and then click `Finish`.

!["Add File Options"][03]

Embed **`THEOplayer SDK`** to the project as illustrated below:

!["Select Embed And Sign"][04]

Optional. Right click on project and `New Group without Folder` to create a logical folder in the project.

!["New group without folder"][05]

Optional. Rename the new group to `Frameworks` which is a common folder name in Xcode projects. Repeat 2 - 4 above but drop the **`THEOplayer SDK`** under the `Frameworks` folder instead:

!["SDK in Frameworks group"][06]

Note: refer to [https://github.com/THEOplayer/theoplayer-sdk-ios] if you want to import the THEOplayer SDK through Cocoapods instead of this manual approach.

## Implementation

The complete implementation can be found in [PlayerViewController.swift] with inline comments. The following sub-sections only highlight the key integration points.

### Create THEOplayer Object And Setup Player View

Import THEOplayer SDK in order to access THEOplayer objects in the view controller.

```swift
    import THEOplayerSDK
```

Instantiate THEOplayer before view controller appears, keep the reference in view controller.

```swift
    class PlayerViewController: UIViewController {

        ...

        var theoplayer: THEOplayer!

        ...

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setupTheoplayer()

            ...
        }

        ...

        private func setupTheoplayer() {
            let playerConfig = THEOplayerConfiguration(
                pip: nil,
                license: "your_license_string"
            )
            theoplayer = THEOplayer(configuration: playerConfig)

            ...
        }

        ...
    }
```

Remember to swap `your_license_string` with your THEOplayer Android SDK license.
You can find your license value on the [THEOplayer Developer Portal](https://portal.theoplayer.com)
associated with your Android SDK, as illustrated by the screenshot below.

![](https://cdn.theoplayer.com/images/git/theoplayer-ios-sdk-license-string.png)

THEOplayer needs to be added as a sub-view of another view (theoplayerView) using the `addAsSubView()` API. Detail on the `THEOPlayerView` class will be covered later.

```swift
    class PlayerViewController: UIViewController {

        ...

        private var theoplayerView: THEOPlayerView!

        ...

        override func viewDidLoad() {
            super.viewDidLoad()

            ...

            setupPlayerView()
        }

        ...

        private func setupPlayerView() {
            theoplayerView = THEOPlayerView() {

                ...
            }

            ...
        }

        ...

        private func setupTheoplayer() {
            let playerConfig = THEOplayerConfiguration(
                pip: nil,
                license: "your_license_string"
            )
            theoplayer = THEOplayer(configuration: playerConfig)
            theoplayer.addAsSubview(of: theoplayerView)

            ...
        }

        ...
    }
```

Set theoplayerView `translatesAutoresizingMaskIntoConstraints` flag to false so that iOS will not scale theoplayerView based on the autoresizing mask. Also, add theoplayerView as a subView  of `view` in `PlayerViewController`.

```swift
    class PlayerViewController: UIViewController {

        ...

        private func setupPlayerView() {
            theoplayerView = THEOPlayerView() {

                ...

            }
            theoplayerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(theoplayerView)

            ...
        }

        ...
    }
```

Apply auto layout constraints against `view`'s `safeAreaLayoutGuide` to avoid any obscuration.

```swift
    class PlayerViewController: UIViewController {

        ...

        private func setupPlayerView() {
            theoplayerView = THEOPlayerView() {

                ...
            }
            theoplayerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(theoplayerView)

            let safeArea = view.safeAreaLayoutGuide
            theoplayerView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
            theoplayerView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor).isActive = true

            theoplayerView.widthAnchor.constraint(equalTo: safeArea.widthAnchor).isActive = true
            theoplayerView.heightAnchor.constraint(equalTo: safeArea.heightAnchor).isActive = true
        }

        ...
    }
```

THEOplayer size and position can be configured with the `frame` property and should be set to match with the theoplayerView frame size at the origin.

```swift
    var playerFrame = theoplayerView.frame
    playerFrame.origin = .zero
    theoplayer.frame = playerFrame
```

THEOplayer frame needs to be updated whenever the size of the theoplayerView changes. It is ok to set THEOplayer frame just once if the size of theoplayerView remains static. In reality, however, the size of theoplayerView is most likely to be dynamic in order to support different iOS device screens in both orientations; hence the auto layout constraints configured above. To keep THEOplayer frame size up-to-date, `THEOPlayerView` is declared as a subClass of `UIView` so that it can update THEOplayer frame using the provided `frameUpdatedClosure` whenever auto layout invokes its `layoutSubviews()` on layout changes. More detail can be found in [Apple UIView Document].

```swift
    class THEOPlayerView: UIView {
        typealias frameUpdatedClosure = (CGRect) -> Void

        private var frameUpdated: frameUpdatedClosure? = nil

        convenience init(frameUpdated: @escaping frameUpdatedClosure) {
            self.init()
            self.frameUpdated = frameUpdated
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            frameUpdated?(frame)
        }
    }

    class PlayerViewController: UIViewController {

        ...

        private func setupPlayerView() {
            theoplayerView = THEOPlayerView(updatedFrame) {
                var playerFrame = updatedFrame
                playerFrame.origin = .zero
                self.theoplayer?.frame = playerFrame
            }
            theoplayerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(theoplayerView)

            let safeArea = view.safeAreaLayoutGuide
            theoplayerView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor).isActive = true
            theoplayerView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor).isActive = true

            theoplayerView.widthAnchor.constraint(equalTo: safeArea.widthAnchor).isActive = true
            theoplayerView.heightAnchor.constraint(equalTo: safeArea.heightAnchor).isActive = true
        }

        ...
    }
```

### Register THEOplayer Event Listeners

The code snippet demonstrates how to listen to various player events. See **`THEOplayer SDK`** documentation for more information.

```swift
    import os.log

    class PlayerViewController: UIViewController {

        ...

        var listeners: [String: EventListener] = [:]

        ...

        private func setupTheoplayer() {

            ...

            attachEventListeners()
        }

        ...

        private func attachEventListeners() {
            listeners["play"] = theoplayer.addEventListener(type: PlayerEventTypes.PLAY, listener: onPlay)
            listeners["playing"] = theoplayer.addEventListener(type: PlayerEventTypes.PLAYING, listener: onPlaying)
            listeners["pause"] = theoplayer.addEventListener(type: PlayerEventTypes.PAUSE, listener: onPause)
            listeners["ended"] = theoplayer.addEventListener(type: PlayerEventTypes.ENDED, listener: onEnded)
            listeners["error"] = theoplayer.addEventListener(type: PlayerEventTypes.ERROR, listener: onError)
        }

        ...

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

        ...
    }
```

### Unload THEOplayer

Stop THEOplayer and unload its resource when the view controller is about to disappear.

```swift
    class PlayerViewController: UIViewController {

        ...

        override func viewWillDisappear(_ animated: Bool) {

            ...

            unloadTheoplayer()
        }

        private func unloadTheoplayer() {
            removeEventListeners()
            theoplayer.stop()
            theoplayer.destroy()
        }

        ...

        private func removeEventListeners() {
            theoplayer.removeEventListener(type: PlayerEventTypes.PLAY, listener: listeners["play"]!)
            theoplayer.removeEventListener(type: PlayerEventTypes.PLAYING, listener: listeners["playing"]!)
            theoplayer.removeEventListener(type: PlayerEventTypes.PAUSE, listener: listeners["pause"]!)
            theoplayer.removeEventListener(type: PlayerEventTypes.ENDED, listener: listeners["ended"]!)
            theoplayer.removeEventListener(type: PlayerEventTypes.ERROR, listener: listeners["error"]!)
            listeners.removeAll()
        }

        ...
    }
```

### Create HLS Source And Trigger Playback

Declare a **`SourceDescription`** property. Describe the source with **`TypedSource`** which is instantiated with a static HLS stream URL and mime type. Assign the source to THEOplayer in **`viewWillAppear`** after THEOplayer is instantiated to trigger playback.

```swift
    class PlayerViewController: UIViewController {

        ...

        private var source: SourceDescription {
            let typedSource = TypedSource(
                src: videoUrl,
                type: mimeType
            )

            return SourceDescription(source: typedSource, poster: posterUrl)
        }

        ...

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setupTheoplayer()
            theoplayer.source = source
        }

        ...
    }
```

## Summary

This guide covered details on how to import and integrate THEOplayer iOS SDK into the reference application project. This includes applying auto layout constrains to player view to adapt different iOS device screen sizes as well as frame resizing during device orientation changes. It also demonstrates how to configure stream source URL and start vide playback with THEOplayer.

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[Import THEOplayer SDK]: #Import-THEOplayer-SDK
[Implementation]: #Implementation
[Create THEOplayer Object and Setup Player View]: #Create-THEOplayer-Object-and-Setup-Player-View
[Register THEOplayer Event Listeners]: #Register-THEOplayer-Event-Listeners
[Unload THEOplayer]: #Unload-THEOplayer
[Create HLS Source and Trigger Playback]: #Create-HLS-Source-and-Trigger-Playback
[Summary]: #Summary

[//]: # (Links and Guides reference)
[THEOplayer How To's - Setup Reference Application]: ../howto-setup-reference-application/README.md
[Apple UIView Document]: https://developer.apple.com/documentation/uikit/uiview
[THEO Docs]: https://docs.portal.theoplayer.com/

[//]: # (Project files reference)
[PlayerViewController.swift]: ../../../Basic_Playback/PlayerViewController.swift

[//]: # (Images references)
[01]: Images/theoplayerSdkContent.png "THEOplayer SDK Content"
[02]: Images/dragAndDropTheoplayerSdk.png "Drag And Drop THEOplayer SDK"
[03]: Images/addFileOptions.png "Add File Options"
[04]: Images/selectEmbedAndSign.png "Select Embed And Sign"
[05]: Images/groupNoFolder.png "New group without folder"
[06]: Images/frameworksGroup.png "SDK in Frameworks group"
