# THEOplayer iOS Reference Apps - THEO Full Screen Handling

This app is an extension of [THEO Basic Playback] application. Please checkout the following guides should any help is needed to get started with Xcode and/or THEOplayer SDK.

* [THEO Knowledge Base - Xcode Setup]
* [THEOplayer How To's - Setup Reference Application]
* [THEOplayer How To's - THEOplayer iOS SDK Integration]

The purpose of this app is to demonstrate how to manage [THEOplayer] presentation mode.

For quick start, please proceed with the [Quick Start](https://docs.theoplayer.com/getting-started/01-sdks/03-ios/00-getting-started.md) guide.

## Quick Start

1. Using the terminal, navigate to the directory where Podfile is located  is located and run:

       pod install --repo-update
       
      &emsp;
      Please keep in mind [the included features](https://github.com/THEOplayer/theoplayer-sdk-ios#included-features) on the Cocoapods releases. If you           want      to use any features other than these, you need to create a custom THEOplayer iOS SDK framework from THEOportal with the features you wish         and embed the    framework in your project instead of using Cocoapods.
      &emsp;
2. On player's configuration, replace the placeholder `your_license_here` with your license for iOS SDK.
      ```swift
        THEOplayerConfiguration(pip: nil, license: "your_license_string")
      ```

      If you don't have a license yet, please visit [THEOportal Getting Started](https://portal.theoplayer.com/getting-started) page.
      &emsp;
3. Open the project `.xcworkspace`, select a Development Team for signing and build it.

## Guides

The guide below will provide a detailed explanation about how to control THEOplayer presentation mode.

* [THEOplayer How To's - Presentation Control]

## License

This project is licensed under the BSD 3 Clause License - see the [LICENSE] file for details.

[//]: # (Links and Guides reference)
[THEOplayer How To's - Presentation Control]: Guides/howto-presentation-control/README.md
[THEO Basic Playback]: ../Basic-Playback
[THEO Knowledge Base - Xcode Setup]: ../Basic-Playback/Guides/knowledgebase-xcode-setup/README.md
[THEO Knowledge Base - Simulator And iOS Device]: ../Basic-Playback/Guides/knowledgebase-simulator-and-ios-device/README.md
[THEOplayer How To's - Setup Reference Application]: ../Basic-Playback/Guides/howto-setup-reference-application/README.md
[THEOplayer How To's - THEOplayer iOS SDK Integration]: ../Basic-Playback/Guides/howto-theoplayer-ios-sdk-integration/README.md
[THEOplayer]: https://www.theoplayer.com
[Get Started with THEOplayer]: https://www.theoplayer.com/licensing
[EZ DRM]: https://www.ezdrm.com/

[//]: # (Project files reference)
[LICENSE]: LICENSE
