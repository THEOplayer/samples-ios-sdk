# THEOplayer How To's - Presentation Control

This guide is going to cover how to control presentation mode in THEOplayer. This includes setting between full screen and inline mode and the use of THEOplayer full screen orientation coupling.

The complete implementation can be found in [PlayerViewController.swift] with inline comments. The following sub-sections only highlight the key points.

## Table of Contents

* [THEOplayer Presentation Mode]
* [Full Screen Orientation Coupling]
* [Presentation Mode Change Event]
* [Summary]

## THEOplayer Presentation Mode

The presentation mode of THEOplayer can be set using the `presentationMode` property, supported modes are:

* **`inline`**: the player will be shown at its original location.
* **`fullscreen`**: the player will play in fullscreen.

Presentation mode will be switched immediately after the property is set. For example the code snippet shows the button handler of the `FULLSCREEN` button in the reference app:

```swift
class PlayerViewController: UIViewController {

    ...

    @objc func onButtonPressed() {
        theoplayer.presentationMode = .fullscreen
    }
}
```

>Note that a THEOplayer FullScreenViewController will be presented when full screen mode is set.

## Full Screen Orientation Coupling

THEOplayer also offers the `fullscreenOrientationCoupling` flag (`false` by default) that couples fullscreen mode and device orientation. This means landscape will be coupled to full screen mode and portrait will be couple to inline mode. The `fullscreenOrientationCoupling` is set to `true` in this reference app as follows:

```swift
class PlayerViewController: UIViewController {

    ...

    private func setupTheoplayer() {
        theoplayer = THEOplayer()
        theoplayer.fullscreenOrientationCoupling = true

        ...
    }

    ...
}
```

## Presentation Mode Change Event

Presentation mode changes can be monitored by listening to the `PlayerEventTypes.PRESENTATION_MODE_CHANGE` event. In the code snippet below, the device is forced to portrait mode when the presentation mode is changed to inline. This is added to handle the case when user uses THEOplayer UI to exit full screen mode when device remains in landscape.

```swift
class PlayerViewController: UIViewController {

    ...

    private func attachEventListeners() {

        ...

        listeners["presentationmodechange"] = theoplayer.addEventListener(type: PlayerEventTypes.PRESENTATION_MODE_CHANGE, listener: onPresentationModeChange)
    }

    private func removeEventListeners() {
        ...

        theoplayer.removeEventListener(type: PlayerEventTypes.PRESENTATION_MODE_CHANGE, listener: listeners["presentationmodechange"]!)

        ...
    }

    private func onPresentationModeChange(event: PresentationModeChangeEvent) {
        os_log("onPresentationModeChange: %@", event.presentationMode.rawValue)
        if event.presentationMode == .inline {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }

    ...
}
```

## Summary

This guide covered different ways to change THEOplayer presentation mode and event that helps to monitor changes of it.

The UI layout of this reference app has been changed to present textual info and a full screen button; the `theoplayerView` is added as a sub view of a `UIStackView` instead of the `view` in `PlayerViewController` along with different set of constraints. Checkout [PlayerViewController.swift] to find out more.

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[THEOplayer Presentation Mode]: #THEOplayer-Presentation-Mode
[Full Screen Orientation Coupling]: #Full-Screen-Orientation-Coupling
[Presentation Mode Change Event]: #Presentation-Mode-Change-Event
[Summary]: #Summary

[//]: # (Links and Guides reference)
[THEO Basic Playback]: ../Basic-Playback
[THEO Docs]: https://docs.portal.theoplayer.com/

[//]: # (Project files reference)
[PlayerViewController.swift]: ../../Full_Screen_Handling/PlayerViewController.swift
