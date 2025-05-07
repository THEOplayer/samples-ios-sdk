# THEOplayer iOS Reference Apps - THEO Basic Playback (SPM)

The purpose of this app is to demonstrate how to integrate [THEOplayer] into an iOS app with SPM and playback a HLS stream.

For a quick start with this sample, please proceed with the [Quick Start](#Quick-Start) section. You can also take a look at our [Getting Started on iOS](https://docs.theoplayer.com/getting-started/01-sdks/03-ios/00-getting-started.md) guide for more information.

## Quick Start

1. Navigate to your Xcode project and switch to the Package Dependencies tab. Click on the + button to add a new SPM package and enter in the search bar the URL of the following repo: https://github.com/THEOplayer/theoplayer-sdk-apple.
       
2. In the player configuration, replace the placeholder `your_license_here` with your license for iOS SDK.

    ```swift
    let playerConfigurationBuilder = THEOplayerConfigurationBuilder()
    playerConfigurationBuilder.license = "your_license_string"
    self.theoplayer = THEOplayer(configuration: playerConfigurationBuilder.build())
    ```

    If you don't have a license yet, please visit [THEOportal Getting Started](https://portal.theoplayer.com/getting-started) page.

3. Open the project `.xcworkspace`, select a Development Team for signing and build it.

## License

This project is licensed under the BSD 3 Clause License - see the [LICENSE] file for details.

[//]: # (Links and Guides reference)
[THEOplayer]: https://www.theoplayer.com
[Get Started with THEOplayer]: https://www.theoplayer.com/pricing/theoplayer

[//]: # (Project files reference)
[LICENSE]: LICENSE
