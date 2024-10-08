# THEOplayer iOS Reference Apps - THEO Google IMA

The purpose of this app is to demonstrate how to integrate [THEOplayer] into an iOS app and integrate with the Google IMA framework to schedule and play advertisements.

For a quick start with this sample, please proceed with the [Quick Start](#Quick-Start) section. You can also take a look at our [Getting Started on iOS](https://docs.theoplayer.com/getting-started/01-sdks/03-ios-unified/00-getting-started.md) guide for more information.

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

## License

This project is licensed under the BSD 3 Clause License - see the [LICENSE] file for details.

[//]: # (Links and Guides reference)
[THEOplayer]: https://www.theoplayer.com
[Get Started with THEOplayer]: https://www.theoplayer.com/pricing/theoplayer

[//]: # (Project files reference)
[LICENSE]: LICENSE
