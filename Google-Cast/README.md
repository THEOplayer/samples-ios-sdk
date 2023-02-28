# THEOplayer iOS Reference Apps - THEO Google Cast

The purpose of this app is to demonstrate how to enable and configure Google Cast functionality in [THEOplayer] and the ability to cast to a neighbouring Cast device.

For a quick start with this sample, please proceed with the [Quick Start](#Quick-Start) section. You can also take a look at our [Getting Started on iOS](https://docs.theoplayer.com/getting-started/01-sdks/03-ios/00-getting-started.md) guide for more information.

## Guides

The guides below will provide a detailed explanation about Google Cast followed by instructions on how to configure Google Cast in THEOplayer.

* [THEOplayer How To's - Google Cast Integration]

This app is an extension of [THEO Basic Playback] application. Please checkout the following guides should any help is needed to get started with Xcode and/or THEOplayer SDK.

* [THEO Knowledge Base - Xcode Setup]
* [THEOplayer How To's - Setup Reference Application]
* [THEOplayer How To's - THEOplayer iOS SDK Integration]

## Quick Start

* Obtain THEOplayer iOS SDK with Google Cast feature enabled. If you don't have a SDK yet, please visit [Get Started with THEOplayer]. At the time of writing, the THEOplayer iOS SDK on CocaoPods [does not include](https://github.com/THEOplayer/theoplayer-sdk-ios#included-features) the Chromecast feature in it and therefore will not work with this sample. To use Chromecast, you will need to build a custom SDK on [THEOportal](https://portal.theoplayer.com/login).
* Extract the downloaded **`iOSSDK-[version]-[name].zip`**. For example:

      unzip iOSSDK-[version]-[name].zip

* Copy & paste the **`THEOplayerSDK.xcframework`** folder to the root of the reference app project. For example:

      cp -a THEOplayerSDK.xcframework/ Google-Cast/

* Download dynamic Google Cast framework from [Google Cast iOS Sender]. We recommend the `.xcframework` if you need M1 Mac support.
* Extract the downloaded **`GoogleCastSDK-ios-[version]_dynamic.zip`**. For example:

      unzip GoogleCastSDK-ios-[version]_dynamic.zip

* Copy & paste the **`GoogleCast.xcframework`** folder to the root of the reference app project. For example:

      cp -a GoogleCastSDK-ios-[version]_dynamic/GoogleCast.xcframework/ Google-Cast/

* Open the reference app project `Google_Cast.xcodeproj` with Xcode.
* Select a Development Team for signing.
* Select `Product > Run` from Xcode menu bar or press `⌘ + R` on the keyboard to build and run the application.
  * Should there be any problems with launching the application, please check the [THEO Knowledge Base - Simulator And iOS Device] guide for more information.

## License

This project is licensed under the BSD 3 Clause License - see the [LICENSE] file for details.

[//]: # (Links and Guides reference)
[THEOplayer How To's - Google Cast Integration]: Guides/howto-google-cast-integration/README.md
[THEO Basic Playback]: ../Basic-Playback
[THEO Knowledge Base - Xcode Setup]: ../Basic-Playback/Guides/knowledgebase-xcode-setup/README.md
[THEO Knowledge Base - Simulator And iOS Device]: ../Basic-Playback/Guides/knowledgebase-simulator-and-ios-device/README.md
[THEOplayer How To's - Setup Reference Application]: ../Basic-Playback/Guides/howto-setup-reference-application/README.md
[THEOplayer How To's - THEOplayer iOS SDK Integration]: ../Basic-Playback/Guides/howto-theoplayer-ios-sdk-integration/README.md
[THEOplayer]: https://www.theoplayer.com
[Get Started with THEOplayer]: https://www.theoplayer.com/pricing/theoplayer
[Google Cast iOS Sender]: https://developers.google.com/cast/docs/ios_sender

[//]: # (Project files reference)
[LICENSE]: LICENSE
