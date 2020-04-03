# THEOplayer How To's - Create Custom UI

This guide is going to cover how to disable THEOplayer default UI and create a functional custom UI in native Swift.

The complete implementation can be found in [PlayerInterfaceView.swift] and [PlayerViewController.swift] with inline comments. The following sub-sections only highlight the key points.

## Table of Contents

* [Disabling THEOplayer default UI]
* [PlayerInterfaceView Overview]
* [Components in PlayerInterfaceView]
  * [Play / PauseButton]
  * [Loading Spinner]
  * [Skip Forward / Backward]
  * [Progress Bar]
  * [Progress Label]
* [Role of PlayerViewController]
* [Full Screen Mode Support]
* [Summary]

## Disabling THEOplayer default UI

The code snippet shows how to disable default UI during THEOplayer initialisation.

Simply create a `THEOplayerConfiguration` object with `chromeless` set to `true` and pass this player configuration object to the `THEOplayer` constructor as follows:

```swift
class PlayerInterfaceView: UIView {

    ...

    private func setupTheoplayer() {
        let playerConfig = THEOplayerConfiguration(chromeless: true)
        theoplayer = THEOplayer(configuration: playerConfig)

        ...
    }

    ...
}
```

## PlayerInterfaceView Overview

`PlayerInterfaceView` is the custom UI implemented to replace the disabled default UI. It is added as sub view of `theoplayerView` and moved on top of THEOplayer. Auto layout constraints are set against `theoplayerView` to match the size. See [Full Screen Mode Support] for more.

`PlayerInterfaceView` does not invoke THEOplayer directly but it offers public properties as follows:

* **`duration`**: Duration of the stream.
* **`currentTime`**: Current time the stream.
* **`state`**: `PlayerInterfaceViewState`

```swift
 enum PlayerInterfaceViewState: Int {
    case initialise
    case buffering
    case playing
    case paused
}
```

* **`delegate`**: `PlayerInterfaceViewDelegate` responsible to perform player control.

```swift
protocol PlayerInterfaceViewDelegate {
    func play()
    func pause()
    func skip(isForward: Bool)
    func seek(timeInSeconds: Float)
}
```

## Components in PlayerInterfaceView

`PlayerInterfaceView` consists of number of UI components, all the components are added during initialisation but only a set of components will be displayed based on the current `state`.

| State              | Components to Display                                              |
| ------------------ |:------------------------------------------------------------------:|
| .initialise        | play button                                                        |
| .buffering         | loading Spinner, skip forward / backward, progress bar, time label |
| .playing           | pause button, skip forward / backward, progress bar, time label    |
| .paused            | play button, skip forward / backward, progress bar, time label     |

### Play / Pause Button

Both play and pause buttons are `UIButton` and they invoke the delegate `play()` and `pause()` functions in the respective event handlers.

```swift
class PlayerInterfaceView: UIView {

    ...

    private func setupControllerStackViewItems() {
        ...

        playButton = setupButton(imageName: "play", isLarge: true)
        playButton.addTarget(self, action: #selector(onPlay), for: .touchUpInside)

        pauseButton = setupButton(imageName: "pause", isLarge: true)
        pauseButton.addTarget(self, action: #selector(onPause), for: .touchUpInside)

        ...
    }

    ...

    @objc private func onPlay() {
        showInterface = true
        delegate?.play()
    }

    @objc private func onPause() {
        showInterface = true
        delegate?.pause()
    }

    ...
}
```

### Loading Spinner

Loading spinner is a `UIActivityIndicatorView` that animates when the `state` is in `.buffering` and stop for all other `state`.

```swift
class PlayerInterfaceView: UIView {

    ...

    private var activityIndicatorView: UIActivityIndicatorView!

    ...

    var state: PlayerInterfaceViewState! {
        didSet {
            ...

            activityIndicatorView.stopAnimating()

            ...

            switch state {

            ...

            case .buffering:
                ...

                activityIndicatorView.startAnimating()

                ...
            ...
            }
        }
    }

    ...

    private func setupActivityIndicatorView() {
        activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)

        controllerStackView.addArrangedSubview(activityIndicatorView)
        activityIndicatorView.widthAnchor.constraint(equalTo: activityIndicatorView.heightAnchor).isActive = true
        activityIndicatorView.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    ...
```

### Skip Forward / Backward

Both skip forward and skip backward buttons are `UIButton` and they both invokes the delegate `skip()` function with the appropriate `isForward` flag.

Both buttons are `UIButton` and they simply invokes the delegate function in their event handlers.

```swift
class PlayerInterfaceView: UIView {

    ...

    private func setupControllerStackViewItems() {
        skipBackwardButton = setupButton(imageName: "skip-backward", isLarge: false)
        skipBackwardButton.addTarget(self, action: #selector(onSkipBackward), for: .touchUpInside)

        ...

        skipForwardButton = setupButton(imageName: "skip-forward", isLarge: false)
        skipForwardButton.addTarget(self, action: #selector(onSkipForward), for: .touchUpInside)
    }

    ...

    @objc private func onSkipBackward() {
        showInterface = true
        delegate?.skip(isForward: false)
    }

    ...

    @objc private func onSkipForward() {
        showInterface = true
        delegate?.skip(isForward: true)
    }

    ...
}
```

### Progress Bar

Progress Bar is a `UISlider` which invoke the delegate's `seek()` function whenever the value changes. Note that additional gesture recognizer is added in order to support tap to seek.

```swift
class PlayerInterfaceView: UIView {

    ...

    private var slider: UISlider!

    ...

    private func setupSlider() {
        slider = THEOComponent.slider()
        slider.addTarget(self, action: #selector(onSliderValueChange), for: .valueChanged)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onSliderTapped))
        slider.addGestureRecognizer(tapGestureRecognizer)

        footerView.addSubview(slider)
        let layoutMarginsGuide = footerView.layoutMarginsGuide
        slider.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        slider.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).isActive = true
        slider.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).isActive = true
    }

    ...

    @objc private func onSliderTapped(gestureRecognizer: UIGestureRecognizer) {
        let tappedPoint: CGPoint = gestureRecognizer.location(in: self)
        let xOffset: CGFloat = tappedPoint.x - slider.frame.origin.x
        var tappedValue: Float = 0.0
        if xOffset > 0 {
            tappedValue = Float((xOffset * CGFloat(slider.maximumValue) / slider.frame.size.width))
        }

        showInterface = true
        slider.setValue(tappedValue, animated: true)
        delegate?.seek(timeInSeconds: tappedValue)
    }

    @objc private func onSliderValueChange(slider: UISlider, event: UIEvent) {
        if let touch = event.allTouches?.first {
            switch touch.phase {
            case .began:
                isDraggingSlider = true
                showInterface = true
                stopAutoHideTimer()
            case .moved:
                currentTimeString = convertTimeString(time: slider.value)
            case .ended:
                isDraggingSlider = false
                delegate?.seek(timeInSeconds: slider.value)
            default:
                break
            }
        }
    }
}
```

### Progress Label

Progress label is constructed by formatting `currentTime` and `duration`. It is updated by setting `currentTimeString` whenever `currentTime` is changed.

```swift
class PlayerInterfaceView: UIView {

    ...

    private var currentTimeString: String = "00:00" {
        didSet {
            progressLabel.text = "\(currentTimeString) / \(durationString)"
        }
    }

    ...

    var duration: Float = 0.0 {
        didSet {
            slider.maximumValue = duration

            isOverHourLong = (duration / 3600) >= 1
            durationString = convertTimeString(time: duration)
        }
    }

    var currentTime: Float = 0.0 {
        didSet {
            if !isDraggingSlider {
                slider.value = currentTime

                currentTimeString = convertTimeString(time: currentTime)
            }
        }
    }

    ...

    private func convertTimeString(time: Float) -> String {
        let seconds = Int(time)
        let (hour, mim, sec) = ((seconds / 3600), ((seconds % 3600) / 60), ((seconds % 3600) % 60))

        if isOverHourLong {
            return String(format: "%02d:%02d:%02d", hour, mim, sec)
        } else {
            return String(format: "%02d:%02d", mim, sec)
        }
    }

    ...
}
```

## Role of PlayerViewController

`PlayerViewController` drives `PlayerInterfaceView` with its public properties. During initialisation, it listens to `PlayerEventTypes.DURATION_CHANGE` and `PlayerEventTypes.TIME_UPDATE` events and set `playerInterfaceView.duration` and `playerInterfaceView.currentTime` in the respective event handler.

```swift
class PlayerViewController: UIViewController {

    ...

    private func attachEventListeners() {

        ...

        listeners["durationChange"] = theoplayer.addEventListener(type: PlayerEventTypes.DURATION_CHANGE, listener: onDurationChange)
        listeners["timeUpdate"] = theoplayer.addEventListener(type: PlayerEventTypes.TIME_UPDATE, listener: onTimeUpdate)

        ...
    }

    private func onDurationChange(event: DurationChangeEvent) {
        os_log("DURATION_CHANGE event, duration: %f", event.duration ?? 0.0)
        if let duration = event.duration, duration.isNormal {
            playerInterfaceView.duration = Float(duration)
        }
    }

    private func onTimeUpdate(event: TimeUpdateEvent) {
        os_log("TIME_UPDATE event, currentTime: %f", event.currentTime)
        if !theoplayer.seeking {
            playerInterfaceView.currentTime = Float(event.currentTime)
        }
    }

    ...
}
```

`PlayerViewController` also conforms to the `PlayerInterfaceViewDelegate` protocol to invoke THEOplayer APIs accordingly.

```swift
extension PlayerViewController: PlayerInterfaceViewDelegate {

    ...

    func play() {
        theoplayer.play()
    }

    func pause() {
        theoplayer.pause()
    }

    func skip(isForward: Bool) {
        theoplayer.requestCurrentTime { (time, error) in
            if let timeInSeconds = time {
                var newTime = timeInSeconds + (isForward ? 10 : -10)
                newTime = newTime < 0 ? 0 : newTime
                if let duration = self.theoplayer.duration {
                    newTime = newTime > duration ? duration : newTime
                }
                self.seek(timeInSeconds: Float(newTime))
            }
        }
    }

    func seek(timeInSeconds: Float) {
        theoplayer.setCurrentTime(Double(timeInSeconds))
        playerInterfaceView.currentTime = timeInSeconds
    }
}
```

Various `PlayerEventTypes` events are listened to update the `state` of  `PlayerInterfaceView`. The following table gives a quick summary on how they are mapped. Please visit [PlayerViewController.swift] to see detailed implementation.

| PlayerEventTypes   | State               |
| ------------------ |:-------------------:|
| PLAY               | .buffering          |
| PLAYING            | .playing            |
| PAUSE              | .paused             |
| SOURCE_CHANGE      | .initialise         |
| READY_STATE_CHANGE | .paused or .playing |
| WAITING            | .buffering          |

## Full Screen Mode Support

In order to support full screen mode, the THEOplayer `fullscreenOrientationCoupling` flag is set to `true` to couple full screen mode with device orientation. This will trigger the `PlayerEventTypes.PRESENTATION_MODE_CHANGE` when device orientation has changed.

When `presentationMode` is in `.fullscreen`, a full screen view controller will be presented by THEOplayer which hides `PlayerViewController` and so as `PlayerInterfaceView`. This full screen view controller is not accessible via THEOplayer object, so in order to display `PlayerInterfaceView` on top of it, `PlayerInterfaceView` needs to be added a sub view of the `window` with a different set of auto layout constraints.

Note that any given `UIView` can only be a sub view of another `UIView`, calling `addSubview()` multiple times will remove itself from the previous parent and so as the associated constraints. This means that there is no need to clean up previous view hierarchy nor removing old constraints during the `presentationMode` switch.

```swift
class PlayerViewController: UIViewController {

    ...

    private func inlinePlayerInterfaceView() {
        theoplayerView.addSubview(playerInterfaceView)

        playerInterfaceView.leadingAnchor.constraint(equalTo: theoplayerView.leadingAnchor).isActive = true
        playerInterfaceView.trailingAnchor.constraint(equalTo: theoplayerView.trailingAnchor).isActive = true
        playerInterfaceView.topAnchor.constraint(equalTo: theoplayerView.topAnchor).isActive = true
        playerInterfaceView.bottomAnchor.constraint(equalTo: theoplayerView.bottomAnchor).isActive = true

        theoplayerView.insertSubview(playerInterfaceView, at: theoplayerView.subviews.count)
    }

    private func fullscreenPlayerInterfaceView() {
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(playerInterfaceView)

            playerInterfaceView.leadingAnchor.constraint(equalTo: window.leadingAnchor).isActive = true
            playerInterfaceView.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
            playerInterfaceView.topAnchor.constraint(equalTo: window.topAnchor).isActive = true
            playerInterfaceView.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
        }
    }

    ...

    private func attachEventListeners() {

      ...

      listeners["presentationModeChange"] = theoplayer.addEventListener(type: PlayerEventTypes.PRESENTATION_MODE_CHANGE, listener: onPresentationModeChange)
    }

    private func onPresentationModeChange(event: PresentationModeChangeEvent) {
        os_log("PRESENTATION_MODE_CHANGE event, presentationMode: %d", event.presentationMode.rawValue)
        if event.presentationMode == .inline {
            inlinePlayerInterfaceView()
        }
        if event.presentationMode == .fullscreen {
            fullscreenPlayerInterfaceView()
        }
    }

    ...
}
```

## Summary

This guide covered how to disable THEOplayer default UI and create a custom UI in native Swift. It also described how the custom UI is interacting with THEOplayer APIs and how to support full screen mode.

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[Disabling THEOplayer default UI]: #Disabling-THEOplayer-default-UI
[PlayerInterfaceView Overview]: #PlayerInterfaceView-Overview
[Components in PlayerInterfaceView]: #Components-in-PlayerInterfaceView
[Play / PauseButton]: #Play-/-Pause-Button
[Loading Spinner]: #Loading-Spinner
[Skip Forward / Backward]: #Skip-Forward-/-Backward
[Progress Bar]: #Progress-Bar
[Progress Label]: #Progress-Label
[Role of PlayerViewController]: #Role-of-PlayerViewController
[Full Screen Mode Support]: #Full-Screen-Mode-Support
[Summary]: #Summary

[//]: # (Links and Guides reference)
[THEO Basic Playback]: ../Basic-Playback
[THEO Docs]: https://docs.portal.theoplayer.com/

[//]: # (Project files reference)
[PlayerInterfaceView.swift]: ../../Custom-UI/PlayerInterfaceView.swift
[PlayerViewController.swift]: ../../Custom-UI/PlayerViewController.swift
