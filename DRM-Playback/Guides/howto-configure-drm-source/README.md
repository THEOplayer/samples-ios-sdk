# THEOplayer How To's - Configure DRM Source

THEOplayer iOS SDK provides support to different [FairPlay Streaming] integration. This guide is going to cover the steps to configure a source description with an [EZ DRM] FairPlay stream.

The complete implementation can be found in [PlayerViewController.swift] with inline comments. The following sub-sections only highlight the key points.

## Table of Contents

* [Creating EZDRM Configuration]
* [Creating Source Description with DRM Configuration]
* [Summary]

## Creating EZDRM Configuration

Use `EzdrmDRMConfiguration` to instantiate a `DRMConfiguration` for EZDRM. FairPlayer license and certificate shall be provided as initialization parameters.

```swift
class PlayerViewController: UIViewController {

    ...

    private var source: SourceDescription {
        let ezdrmDrmConfig = EzdrmDRMConfiguration(
            licenseAcquisitionURL: licenseUrl,
            certificateURL: certificateUrl
        )

        ...
    }

    ...
}
```

## Creating Source Description with DRM Configuration

`TypedSource` will be used just as [THEO Basic Playback] except that the `EzdrmDRMConfiguration` will be passed as the `drm` property.

```swift
class PlayerViewController: UIViewController {

    ...

    private var source: SourceDescription {
        let ezdrmDrmConfig = EzdrmDRMConfiguration(
            licenseAcquisitionURL: licenseUrl,
            certificateURL: certificateUrl
        )

        let typedSource = TypedSource(
            src: videoUrl,
            type: mimeType,
            drm: ezdrmDrmConfig
        )

        return SourceDescription(source: typedSource)
    }

    ...
}
```

## Summary

Source description with DRM stream has been created successfully. When the `source` property is invoked, the DRM source description will be returned and then played by THEOplayer.

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[Creating EZDRM Configuration]: #Creating-EZDRM-Configuration
[Creating Source Description with DRM Configuration]: #Creating-Source-Description-with-DRM-Configuration
[Summary]: #Summary

[//]: # (Links and Guides reference)
[THEO Basic Playback]: ../Basic-Playback
[FairPlay Streaming]: https://developer.apple.com/streaming/fps/
[EZ DRM]: https://www.ezdrm.com/
[THEO Docs]: https://docs.portal.theoplayer.com/

[//]: # (Project files reference)
[PlayerViewController.swift]: ../../DRM_Playback/PlayerViewController.swift
