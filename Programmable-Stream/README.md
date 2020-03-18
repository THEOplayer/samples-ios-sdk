# THEOplayer iOS Reference Apps - THEO Programmable Stream

The purpose of this app is to easily reproduce any [THEOplayer] configuration.

## Getting Started

* Obtain THEOplayer SDK with Google IMA and Google Cast features enabled. If you don't have a SDK yet, please visit [Get Started with THEOplayer].
* Copy & paste the unzipped **_THEOplayerSDK.framework_** folder to the root of the reference app project. For example:

        cp -a THEOplayerSDK.framework/ Programmable-Stream/

* Download dynamic Goolge Cast framework from [Google].
* Copy & paste the unzipped **_GoogleCast.framework_** folder to the root of the reference app project. For example:

        cp -a GoogleCastSDK-ios-4.4.6_dynamic/GoogleCast.framework/ Google-Cast/

## Streams/Content Rights:

The DRM streams used in this app (if any) are provided by our Partner: [EZ DRM] and hold all the rights for the content. These streams are DRM protected and cannot be used for any other purposes.

## License

This project is licensed under the BSD 3 Clause License - see the [LICENSE] file for details.

[//]: # (Links reference)
[THEOplayer]: https://www.theoplayer.com
[Get Started with THEOplayer]: https://www.theoplayer.com/licensing
[Google]: https://developers.google.com/cast/docs/ios_sender
[EZ DRM]: https://www.ezdrm.com/

[//]: # (Project files reference)
[LICENSE]: ./LICENSE
