# THEOplayer How To's - Ads Insertion

This guide is going to cover the steps to insert ads to the HLS stream to [THEO Basic Playback] using the default THEO ads module.

The complete implementation can be found in [PlayerViewController.swift] with inline comments. The following sub-sections only highlight the key points.

## Table of Contents

* [THEO Ad Description]
  * [VAST Linear Pre-Roll]
  * [VAST Non-linear Pre-Roll]
  * [VAST Mid-Roll]
  * [Skippable VAST Mid-Roll]
  * [VAST Post-Roll]
  * [VMAP]
* [Creating SourceDescription With Ads Array]
* [Ads Event Listeners]
* [Summary]

## THEO Ad Description

In order to make use of the THEO default ads module, `THEOAdDescription` which confronts to the `AdDescription` protocol shall be used to describe a given ads.

`THEOAdDescription` expects the following initialization parameters:

* **`src`** - URL to the VAST or VMAP XML file.
* **`timeOffset`** - an optional VAST only parameter that specifies when the ad should be played. Support `start`, `end` and percentage (e.g. `10%`)
* **`skipOffset`** - an optional VAST only parameter that specifies when a linear ad can be skipped. Support percentage value that is less than 100%, for example `50%`.

`THEOAdDescription` is ads type agnostic hence it can be used to create `AdDescription` for both VAST and VMAP ads.

### VAST Linear Pre-Roll

```swift
THEOAdDescription(src: <Linear VAST ad URL>)
```

### VAST Non-linear Pre-Roll

```swift
THEOAdDescription(src: <Non-linear VAST ad URL>)
```

### VAST Mid-Roll

```swift
THEOAdDescription(src: <VAST ad URL>, timeOffset: "2%")
```

### Skippable VAST Mid-Roll

```swift
THEOAdDescription(src: <VAST ad URL>, timeOffset: "2%", skipOffset: "10%")
```

### VAST Post-Roll

```swift
THEOAdDescription(src: <VAST ad URL>, timeOffset: "end")
```

### VMAP

```swift
THEOAdDescription(src: <VMAP ad URL>)
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

Instantiate `THEOAdDescription` object(s) as shown in [THEO Ad Description] and append them to the `vastAdDescs` array.

```swift
class PlayerViewController: UIViewController {

    ...

    private var source: SourceDescription {

        ...

        var vastAdDescs: [AdDescription] = [AdDescription]()
        vastAdDescs.append(THEOAdDescription(src: <Linear VAST ad URL>))
        vastAdDescs.append(THEOAdDescription(src: <Non-linear VAST ad URL>))
        vastAdDescs.append(THEOAdDescription(src: <VAST ad URL>), timeOffset: "2%")

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
        vastAdDescs.append(THEOAdDescription(src: <Linear VAST ad URL>))
        vastAdDescs.append(THEOAdDescription(src: <Non-linear VAST ad URL>))
        vastAdDescs.append(THEOAdDescription(src: <VAST ad URL>), timeOffset: "2%")

        var vmapAdDescs: [AdDescription] = [AdDescription]()
        vmapAdDescs.append(THEOAdDescription(src: <VMAP ad URL>))

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

This guide has covered how to use THEO ads module to instantiate ads object to pass to the source description. When the `source` property is invoked, the ads inserted source description will be returned and then played by THEOplayer.

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[THEO Ad Description]: #THEO-Ad-Description
[VAST Linear Pre-Roll]: #VAST-Linear-Pre-Roll
[VAST Non-linear Pre-Roll]: #VAST-Non-linear-Pre-Roll
[VAST Mid-Roll]: #VAST-Mid-Roll
[Skippable VAST Mid-Roll]: #Skippable-VAST-Mid-Roll
[VAST Post-Roll]: #VAST-Post-Roll
[VMAP]: #VMAP
[Creating SourceDescription With Ads Array]: #Creating-SourceDescription-With-Ads-Array
[Ads Event Listeners]: #Ads-Event-Listeners
[Optional - VMAP Ad URL]: #Optional---VMAP-Ad-URL
[Expected Result]: #Expected-Result
[Summary]: #Summary

[//]: # (Links and Guides reference)
[THEO Basic Playback]: ../Basic-Playback
[THEO Docs]: https://docs.portal.theoplayer.com/

[//]: # (Project files reference)
[PlayerViewController.swift]: ../../DRM_Playback/PlayerViewController.swift
