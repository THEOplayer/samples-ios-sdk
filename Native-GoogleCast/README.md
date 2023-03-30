# THEOplayer iOS Reference Apps - THEO Native GoogleCast

The purpose of this app is to demonstrate how to integrate [THEOplayer] into an iOS app and integrate with the Google Cast framework to act as the sender application during chromecast.

For a quick start with this sample, please proceed with the [Quick Start](#Quick-Start) section. You can also take a look at our [Getting Started on iOS](https://docs.theoplayer.com/getting-started/01-sdks/03-ios/00-getting-started.md) guide for more information.

Please check out the following guides should any help be needed to get started with Xcode and/or THEOplayer SDK.

* [THEO Knowledge Base - Xcode Setup]
* [THEO Knowledge Base - Simulator And iOS Device]
* [THEOplayer How To's - Setup Reference Application]
* [THEOplayer How To's - THEOplayer iOS SDK Integration]

## Quick Start

1. Using the terminal, navigate to the directory where Podfile is located and run:

       pod install --repo-update
       
      &emsp;
   Please keep in mind [the included features](https://github.com/THEOplayer/theoplayer-sdk-ios#included-features) on the Cocoapods releases. If you want to use any features other than these, you need to create a custom THEOplayer iOS SDK framework from THEOportal with the features you wish and embed the framework in your project instead of using Cocoapods.
      &emsp;
2. In the player configuration, replace the placeholder `your_license_here` with your license for iOS SDK.
      ```swift
        THEOplayerConfiguration(pip: nil, license: "your_license_string")
      ```

      If you don't have a license yet, please visit [THEOportal Getting Started](https://portal.theoplayer.com/getting-started) page.
      &emsp;
3. Open the project `.xcworkspace`, select a Development Team for signing and build it.

## License

This project is licensed under the BSD 3 Clause License - see the [LICENSE] file for details.

[//]: # (Links and Guides reference)
[THEOplayer]: https://www.theoplayer.com
[Get Started with THEOplayer]: https://www.theoplayer.com/pricing/theoplayer

[//]: # (Project files reference)
[LICENSE]: LICENSE
