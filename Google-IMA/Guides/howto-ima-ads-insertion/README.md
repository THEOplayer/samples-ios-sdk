# THEOplayer How To's - Ads Insertion with Google IMA

This guide is going to cover the steps to insert ads to the HLS stream to [THEO Basic Playback] using Google IMA module.

The complete implementation can be found in [PlayerViewController.swift] with inline comments. The following sub-sections only highlight the key points.

## Table of Contents

* [Enabling Google IMA]
* [Google IMA Ad Description]
  * [VAST Linear Pre-Roll]
  * [VAST Non-linear Pre-Roll]
  * [VAST Mid-Roll]
  * [VAST Post-Roll]
  * [VPAID Mid-Roll]
  * [VMAP]
* [Creating SourceDescription With Ads Array]
* [Ads Event Listeners]
* [Summary]

## Enabling Google IMA

The code snippet shows how to enable Google IMA during THEOplayer initialisation.

Simply create a `THEOplayerConfiguration` object with `googleIMA` set to `true` and pass this player configuration object to the `THEOplayer` constructor as follows:

```swift
class PlayerViewController: UIViewController {

    ...

    private func setupTheoplayer() {
        let playerConfig = THEOplayerConfiguration(googleIMA: true)
        theoplayer = THEOplayer(configuration: playerConfig)

        ...
    }

    ...
}
```

## Google IMA Ad Description

In order to make use of the Google IMA module, `GoogleImaAdDescription` which confronts to the `AdDescription` protocol shall be used to describe a given ads.

`GoogleImaAdDescription` expects the following initialization parameters:

* **`src`** - URL to the VAST, VMAP or VPAID XML file.
* **`timeOffset`** - an optional VAST only parameter that specifies when the ad should be played. Support `start`, `end` and percentage (e.g. `10%`)

`GoogleImaAdDescription` is ads type agnostic hence it can be used to create `AdDescription` for all ads.

### VAST Linear Pre-Roll

```swift
GoogleImaAdDescription(src: <Linear VAST ad URL>)
```

### VAST Non-linear Pre-Roll

```swift
GoogleImaAdDescription(src: <Non-linear VAST ad URL>)
```

### VAST Mid-Roll

```swift
GoogleImaAdDescription(src: <VAST ad URL>, timeOffset: "2%")
```

### VPAID Mid-Roll

```swift
GoogleImaAdDescription(src: <VPAID ad URL>, timeOffset: "4%")
```

### VAST Post-Roll

```swift
GoogleImaAdDescription(src: <VAST ad URL>, timeOffset: "end")
```

### VMAP

```swift
GoogleImaAdDescription(src: <VMAP ad URL>)
```

To find out more, please see the `THEOplayer iOS SDK` documentation.

## Creating SourceDescription With Ads Array

The `SourceDescription` expects an array of `AdDescription` to be passed to its `ads` parameter, therefore an `AdDescription` array is created in [PlayerViewController.swift] before the `SourceDescription` computed property returns.

```swift
class PlayerViewController: UIViewController {

    ...

    private var source: SourceDescription {

        ...

        var vastAdDescs: [AdDescription] = [AdDescription]()

        ...

        return SourceDescription(source: typedSource, ads: vastAdDescs, poster: posterUrl)
    }

    ...
}
```

Instantiate `GoogleImaAdDescription` object(s) as shown in [THEO Ad Description] and append them to the `vastAdDescs` array.

```swift
class PlayerViewController: UIViewController {

    ...

    private var source: SourceDescription {

        ...

        var vastAdDescs: [AdDescription] = [AdDescription]()
        vastAdDescs.append(GoogleImaAdDescription(src: <Linear VAST ad URL>))
        vastAdDescs.append(GoogleImaAdDescription(src: <Non-linear VAST ad URL>))
        vastAdDescs.append(GoogleImaAdDescription(src: <VAST ad URL>), timeOffset: "2%")
        vastAdDescs.append(GoogleImaAdDescription(src: <VPAID ad URL>), timeOffset: "4%")

        return SourceDescription(source: typedSource, ads: vastAdDescs, poster: posterUrl)
    }
    ...
}
```

In [PlayerViewController.swift], a separate `AdDescription` array has been added for VMAP demonstration. The set of `AdDescription` array to be used is controlled by the `useVast` flag which is set to `true` by default.

```swift
class PlayerViewController: UIViewController {

    ...

    private var source: SourceDescription {

        ...
        let useVast: Bool = true

        var vastAdDescs: [AdDescription] = [AdDescription]()
        vastAdDescs.append(GoogleImaAdDescription(src: <Linear VAST ad URL>))
        vastAdDescs.append(GoogleImaAdDescription(src: <Non-linear VAST ad URL>))
        vastAdDescs.append(GoogleImaAdDescription(src: <VAST ad URL>), timeOffset: "2%")
        vastAdDescs.append(GoogleImaAdDescription(src: <VPAID ad URL>), timeOffset: "4%")

        var vmapAdDescs: [AdDescription] = [AdDescription]()
        vmapAdDescs.append(GoogleImaAdDescription(src: <VMAP ad URL>))

        return SourceDescription(source: typedSource, ads: useVast ? vastAdDescs : vmapAdDescs, poster: posterUrl)
    }
    ...
}
```

## Ads Event Listeners

The code snippet demonstrates how to add and remove listen to the `AD_BEGIN`, `AD_END` and `AD_ERROR` events. See `THEOplayer iOS SDK` documentation for more information.

```swift
class PlayerViewController: UIViewController {

    ...

    private func attachEventListeners() {

        ...

        listeners["adBegin"] = theoplayer.ads.addEventListener(type: AdsEventTypes.AD_BEGIN, listener: onAdBegin)
        listeners["adEnd"] = theoplayer.ads.addEventListener(type: AdsEventTypes.AD_END, listener: onAdEnd)
        listeners["adError"] = theoplayer.ads.addEventListener(type: AdsEventTypes.AD_ERROR, listener: onAdError)
    }

    private func removeEventListeners() {

        ...

        theoplayer.ads.removeEventListener(type: AdsEventTypes.AD_BEGIN, listener: listeners["adBegin"]!)
        theoplayer.ads.removeEventListener(type: AdsEventTypes.AD_END, listener: listeners["adEnd"]!)
        theoplayer.ads.removeEventListener(type: AdsEventTypes.AD_ERROR, listener: listeners["adError"]!)

        ...
    }

    ...

    private func onAdBegin(event: AdBeginEvent) {
        os_log("AD_BEGIN event, adId: %@", event.ad?.id ?? "nil")
    }

    private func onAdEnd(event: AdEndEvent) {
        os_log("AD_END event, adId: %@", event.ad?.id ?? "nil")
    }

    private func onAdError(event: AdErrorEvent) {
        os_log("AD_ERROR event, adId: %@, error: %@", event.ad?.id ?? "nil", event.error ?? "nil")
    }
}
```

## Summary

This guide has covered how to enable Google IMA in THEOplayer and use Google IMA module to instantiate ads object to pass to the source description. When the `source` property is invoked, the ads inserted source description will be returned and then played by THEOplayer.

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[Enabling Google IMA]: #Enabling-Google-IMA
[Google IMA Ad Description]: #Google-IMA-Ad-Description
[VAST Linear Pre-Roll]: #VAST-Linear-Pre-Roll
[VAST Non-linear Pre-Roll]: #VAST-Non-linear-Pre-Roll
[VAST Mid-Roll]: #VAST-Mid-Roll
[VAST Post-Roll]: #VAST-Post-Roll
[VPAID Mid-Roll]: #VPAID-Mid-Roll
[VMAP]: #VMAP
[Creating SourceDescription With Ads Array]: #Creating-SourceDescription-With-Ads-Array
[Ads Event Listeners]: #Ads-Event-Listeners
[Summary]: #Summary

[//]: # (Links and Guides reference)
[THEO Basic Playback]: ../Basic-Playback
[THEO Docs]: https://docs.portal.theoplayer.com/

[//]: # (Project files reference)
[PlayerViewController.swift]: ../../Google_IMA/PlayerViewController.swift
