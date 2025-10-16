# OptiView Player iOS Reference Apps - DRM Playback

The purpose of this app is to demonstrate how to playback a DRM protected HLS stream with [OptiView Player] (formerly THEOplayer).

For a quick start with this sample, please proceed with the [Quick Start](#Quick-Start) section. You can also take a look at our [Getting Started on iOS](https://optiview.dolby.com/docs/theoplayer/getting-started/sdks/ios/getting-started/) guide for more information.

## Guides

The guides below will provide a detailed explanation about DRM systems followed by instructions on how to configure DRM source for DRM protected streams and play it with OptiView Player.

* [OptiView Knowledge Base - DRM Systems]
* [OptiView How To's - Configure DRM Source]

## Quick Start

1. Navigate to your Xcode project and switch to the Package Dependencies tab. Click on the + button to add a new SPM package and enter in the search bar the URL of the following repo: https://github.com/THEOplayer/theoplayer-sdk-apple.

2. Add the `THEOplayerSDK` to your project.
       
3. In the player configuration, replace the placeholder `your_license_here` with your license for iOS SDK.

    ```swift
    let playerConfigurationBuilder = THEOplayerConfigurationBuilder()
    playerConfigurationBuilder.license = "your_license_string"
    self.theoplayer = THEOplayer(configuration: playerConfigurationBuilder.build())
    ```

    If you don't have a license yet, please visit [THEOportal Getting Started](https://portal.theoplayer.com/getting-started) page.

4. Open the project `.xcodeproj`, select a Development Team for signing and build it.

## Streams/Content Rights

The DRM streams used in this app (if any) are provided by our Partner: [EZ DRM] and hold all the rights for the content. These streams are DRM protected and cannot be used for any other purposes.

## OptiView Player License Required

This app uses a source hosted on the ezdrm.com domain. Provide a valid OptiView Player license that includes the EZ DRM domain for playback to start.

## License

This project is licensed under the BSD 3 Clause License - see the [LICENSE] file for details.

[//]: # (Links and Guides reference)
[OptiView Knowledge Base - DRM Systems]: https://optiview.dolby.com/docs/theoplayer/knowledge-base/content-protection/drm-systems//
[OptiView How To's - Configure DRM Source]: Guides/howto-configure-drm-source/README.md
[OptiView Player - Basic Playback Sample]: ../Basic-Playback
[OptiView Player]: https://optiview.dolby.com/products/video-player/
[Get Started with OptiView]: https://optiview.dolby.com/plans/
[EZ DRM]: https://www.ezdrm.com/

[//]: # (Project files reference)
[LICENSE]: LICENSE
