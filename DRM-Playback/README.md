# THEOplayer iOS Reference Apps - THEO DRM Playback

The purpose of this app is to demonstrate how to playback a DRM protected HLS stream with [THEOplayer].

For a quick start with this sample, please proceed with the [Quick Start](#Quick-Start) section. You can also take a look at our [Getting Started on iOS](https://docs.theoplayer.com/getting-started/01-sdks/03-ios/00-getting-started.md) guide for more information.

## Guides

The guides below will provide a detailed explanation about DRM systems followed by instructions on how to configure DRM source for DRM protected streams and play it with THEOplayer.

* [THEO Knowledge Base - DRM Systems]
* [THEOplayer How To's - Configure DRM Source]

## Quick Start

1. Using the terminal, navigate to the directory where the Podfile is located and run:

        pod install --repo-update

2. In the player configuration, replace the placeholder `your_license_here` with your license for iOS SDK.
    ```swift
    let playerConfigurationBuilder = THEOplayerConfigurationBuilder()
    playerConfigurationBuilder.license = "your_license_string"
    self.theoplayer = THEOplayer(configuration: playerConfigurationBuilder.build())
    ```

    If you don't have a license yet, please visit [THEOportal Getting Started](https://portal.theoplayer.com/getting-started) page.
3. Open the project `.xcworkspace`, select a Development Team for signing and build it.

## Streams/Content Rights

The DRM streams used in this app (if any) are provided by our Partner: [EZ DRM] and hold all the rights for the content. These streams are DRM protected and cannot be used for any other purposes.

## THEOplayer License Required

This app uses a source hosted on the ezdrm.com domain. Provide a valid THEOplayer license that includes the ezdrm domain for playback to start.

## License

This project is licensed under the BSD 3 Clause License - see the [LICENSE] file for details.

[//]: # (Links and Guides reference)
[THEO Knowledge Base - DRM Systems]: https://www.theoplayer.com/docs/theoplayer/knowledge-base/content-protection/drm-systems/
[THEOplayer How To's - Configure DRM Source]: Guides/howto-configure-drm-source/README.md
[THEO Basic Playback]: ../Basic-Playback
[THEOplayer]: https://www.theoplayer.com
[Get Started with THEOplayer]: https://www.theoplayer.com/licensing
[EZ DRM]: https://www.ezdrm.com/

[//]: # (Project files reference)
[LICENSE]: LICENSE
