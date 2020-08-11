# THEOplayer How To's - Picture in Picture Configuration

This guide is going to cover how to enable and config Picture in Picture mode in THEOplayer.

The complete implementation can be found in [PlayerViewController.swift] with inline comments. The following sub-sections only highlight the key points.

## Table of Contents

* [Enable Picture in Picture Mode]
* [Configure Picture in Picture Mode]
* [Summary]

## Enable Picture in Picture Mode

The code snippet shows how to enable Picture in Picture during THEOplayer initialisation.

Simply create a `THEOplayerConfiguration` object with `pip` and create the `PiPConfiguration` to set the `retainPresentationModeOnSourceChange: true` and pass this player configuration object to the `THEOplayer` constructor as follows:

```swift
class PlayerViewController: UIViewController {

    ...

    private func setupTheoplayer() {
        let playerConfig = THEOplayerConfiguration(pip: PiPConfiguration(retainPresentationModeOnSourceChange: true))
        theoplayer = THEOplayer(configuration: playerConfig)

        ...
    }

    ...
}
```

## Configure Picture in Picture Mode

The `PictureInPicture` object in `THEOplayer` offers the `configure()` API to customise properties of the PiP window:

* **`movable`**: Indicates whether or not the PiP view is movable
* **`defaultCorner`**: Indicates the default corner at which the PiP view will appear when entering PiP mode
* **`scale:`** Indicates the scale of the PiP view default to 0.33
* **`visibility`**: (from 0 to 1) The maximum percentage of the original player position that should be visible to enable picture-in-picture automatically.
* **`margin`**: The THEOMargins value indicating the distance between the PiP view and the screen. It has a `THEOMargins` API to customise the margins for `all`, `horizontal` & `vertical` or set all seperately for `top`, `right`, `bottom` and `left`. The deafult is set to nil taking screen ratio into consideration.

If not configured, picture-in-picture can only be turned on by setting presentationMode to pictureInPicture. default to nil

For example:

```swift
class PlayerViewController: UIViewController {

    ...

    private func setupTheoplayer() {
        let playerConfig = THEOplayerConfiguration(pip: PiPConfiguration(retainPresentationModeOnSourceChange: true))
        theoplayer = THEOplayer(configuration: playerConfig)
        theoplayer.pip?.configure(movable: true, defaultCorner: .bottomLeft, scale: 0.33, visibility: nil, margin: THEOMargins(all: 20))

        ...
    }

    ...
}
```
* Note : The above pip configuration is only available in THEOplayer iOS SDK Version 2.74 and above

## Summary

Picture in Picture mode is now enabled and configured. An additional button will be available in THEOplayer default controller interface, pressing it will switch player in the PiP window.

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[Enable Picture in Picture Mode]: #Enable-Picture-in-Picture-Mode
[Configure Picture in Picture Mode]: #Configure-Picture-in-Picture-Mode
[Summary]: #Summary

[//]: # (Links and Guides reference)
[THEO Basic Playback]: ../Basic-Playback
[THEO Docs]: https://docs.portal.theoplayer.com/

[//]: # (Project files reference)
[PlayerViewController.swift]: ../../PiP_Handling/PlayerViewController.swift
