# OptiView Player iOS Reference Apps - Streaming (Millicast)

The purpose of this app is to demonstrate how to integrate [OptiView Player] (formerly THEOplayer) into an iOS app with SPM and playback a Millicast stream.

For a quick start with this sample, please proceed with the [Quick Start](#Quick-Start) section. You can also take a look at our [Getting Started on iOS](https://optiview.dolby.com/docs/theoplayer/getting-started/sdks/ios/getting-started/) guide for more information.

## Quick Start

1. Navigate to your Xcode project and switch to the Package Dependencies tab. Click on the + button to add a new SPM package and enter in the search bar the URL of the following repo: https://github.com/THEOplayer/theoplayer-sdk-apple.

2. Add the `THEOplayerSDK` and `THEOplayerMillicastIntegration` to your project.

(Only if using SPM): Also add `MillicastSDK` from the https://github.com/millicast/millicast-sdk-swift-package repo to your project by following the same steps. This step is not necessary if you are using Cocoapods, in which case the `THEOplayerMillicastIntegration` can automatically pull the `MillicastSDK` dependency while fetching the pods.
       
3. In the player configuration, replace the placeholder `your_license_here` with your license for iOS SDK.

    ```swift
    let playerConfigurationBuilder = THEOplayerConfigurationBuilder()
    playerConfigurationBuilder.license = "your_license_string"
    self.theoplayer = THEOplayer(configuration: playerConfigurationBuilder.build())
    ```

    If you don't have a license yet, please visit [THEOportal Getting Started](https://portal.theoplayer.com/getting-started) page.

4. Open the project `.xcworkspace`, select a Development Team for signing and build it.

## License

This project is licensed under the BSD 3 Clause License - see the [LICENSE] file for details.

[//]: # (Links and Guides reference)
[OptiView Player]: https://optiview.dolby.com/products/video-player/
[Get Started with OptiView]: https://optiview.dolby.com/plans/
[Getting started with Millicast for iOS]: https://optiview.dolby.com/docs/millicast/playback/players-sdks/ios/player/

[//]: # (Project files reference)
[LICENSE]: LICENSE