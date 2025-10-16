# OptiView Player iOS Reference Apps - Offline Playback

The purpose of this app is to demonstrate how [OptiView Player] (formerly THEOplayer) can be used to download protected and unprotected content for offline playback.

For quick start, please proceed with the [Quick Start](#Quick-Start) guide and make sure to run the app on a real device because offline playback is not supported in simulators.

## Guides

The guides below will provide a detailed explanation about caching stream for offline playback using OptiView Player Cache API.

* [OptiView Player How To's - Offline Stream Caching]

This app is an extension of the [Basic Playback] sample. Please checkout the following guides should any help is needed to get started with Xcode and/or OptiView Player SDK.

* [OptiView Knowledge Base - Xcode Setup]
* [OptiView How To's - Setup Reference Application]
* [OptiView How To's - OptiView Player iOS SDK Integration]

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

## License

This project is licensed under the BSD 3 Clause License - see the [LICENSE] file for details.

[//]: # (Links and Guides reference)
[OptiView How To's - Offline Stream Caching]: Guides/howto-offline-stream-caching/README.md
[Basic Playback]: ../Basic-Playback
[OptiView Player]: https://optiview.dolby.com/products/video-player/
[Get Started with OptiView]: https://optiview.dolby.com/plans/
[EZ DRM]: https://www.ezdrm.com/

[//]: # (Project files reference)
[LICENSE]: LICENSE
