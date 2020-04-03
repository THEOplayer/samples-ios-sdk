# THEOplayer iOS Reference Apps - THEO Simple OTT

The purpose of this app is to demonstrate how [THEOplayer] could be used in a "real" production-like application.

For quick start, please proceed with the [Quick Start](#Quick-Start) guide.

## Architecture Overview

The following diagram illustrated the overall architecture of this reference app.

!["Simple OTT Architecture Diagram"][01]

## Guides

This app is an extension of [THEO Basic Playback] application. Please checkout the following guides should any help is needed to get started with Xcode and/or THEOplayer SDK.

* [THEO Knowledge Base - Xcode Setup]
* [THEOplayer How To's - Setup Reference Application]
* [THEOplayer How To's - THEOplayer iOS SDK Integration]

Numerous THEOplayer features demonstrated in other reference apps are enabled in this app, this includes `Google IMA`, `Google Cast`, `Picture in Picture` and `Offline-Playback`. Please checkout the following links for the guides to these features.

* [THEOplayer How To's - Ads Insertion with Google IMA]
* [THEOplayer How To's - Google Cast Integration]
* [THEOplayer How To's - Picture in Picture Configuration]
* [THEOplayer How To's - Offline Stream Caching]

## Quick Start

* Obtain THEOplayer iOS SDK with Google Cast features enabled. If you don't have a SDK yet, please visit [Get Started with THEOplayer].
* Extract the downloaded **`iOSSDK-[version]-[name].zip`**. For example:

      unzip iOSSDK-[version]-[name].zip

* Copy & paste the **`THEOplayerSDK.framework`** folder to the root of the reference app project. For example:

      cp -a THEOplayerSDK.framework/ Simple-OTT/

* Download dynamic Google Cast framework from [Google Cast iOS Sender].
* Extract the downloaded **`GoogleCastSDK-ios-[version]_dynamic.zip`**. For example:

      unzip GoogleCastSDK-ios-[version]_dynamic.zip

* Copy & paste the **`GoogleCast.framework`** folder to the root of the reference app project. For example:

      cp -a GoogleCastSDK-ios-[version]_dynamic/GoogleCast.framework/ Simple-OTT/

* Follow [Cocoapods Installation Guide] to install Cocoapods if it is not already installed.
* Install Cocoapods dependencies at the root of the reference app folder:

      cd Simple-OTT/
      pod install

* Sign in Xcode with an enrolled Apple Developer account.
  * Required for `Access WiFi Information`, see [Apple Developer Program] for more info.
* Open the reference app project `Simple_OTT.xcworkspace` with Xcode.
* Select `Product > Run` from Xcode menu bar or press `⌘ + R` on the keyboard to build and run the application.
  * Should there be any problems with launching the application, please check the [THEO Knowledge Base - Simulator And iOS Device] guide for more information.

## Streams/Content Rights

The DRM streams used in this app (if any) are provided by our Partner: [EZ DRM] and hold all the rights for the content. These streams are DRM protected and cannot be used for any other purposes.

## License

This project is licensed under the BSD 3 Clause License - see the [LICENSE] file for details.

[//]: # (Links and Guides reference)
[PlayerConfiguration]: https://docs.portal.theoplayer.com/docs/api-reference/theoplayer-playerconfiguration/
[SourceDescription]: https://docs.portal.theoplayer.com/docs/api-reference/theoplayer-sourcedescription/
[THEO Basic Playback]: ../Basic-Playback
[THEO Knowledge Base - Xcode Setup]: ../Basic-Playback/Guides/knowledgebase-xcode-setup/README.md
[THEO Knowledge Base - Simulator And iOS Device]: ../Basic-Playback/Guides/knowledgebase-simulator-and-ios-device/README.md
[THEOplayer How To's - Setup Reference Application]: ../Basic-Playback/Guides/howto-setup-reference-application/README.md
[THEOplayer How To's - THEOplayer iOS SDK Integration]: ../Basic-Playback/Guides/howto-theoplayer-ios-sdk-integration/README.md
[THEOplayer How To's - Ads Insertion with Google IMA]: ../Google-IMA/Guides/howto-ima-ads-insertion/README.md
[THEOplayer How To's - Google Cast Integration]: ../Google-Cast/Guides/howto-google-cast-integration/README.md
[THEOplayer How To's - Picture in Picture Configuration]: ../PiP-Handling/Guides/howto-pip-configuration/README.md
[THEOplayer How To's - Offline Stream Caching]: ../Offline-Playback/Guides/howto-offline-stream-caching/README.md
[THEOplayer]: https://www.theoplayer.com
[Get Started with THEOplayer]: https://www.theoplayer.com/licensing
[Google Cast iOS Sender]: https://developers.google.com/cast/docs/ios_sender
[Cocoapods Installation Guide]: https://guides.cocoapods.org/using/getting-started.html#getting-started
[Apple Developer Program]: https://developer.apple.com/support/compare-memberships/
[EZ DRM]: https://www.ezdrm.com/

[//]: # (Project files reference)
[LICENSE]: LICENSE

[//]: # (Images references)
[01]: Guides/Images/SimpleOTTArchitecture.png "Simple OTT Architecture Diagram"
