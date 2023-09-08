# THEOplayer How To's - Configure DRM Source

THEOplayer iOS SDK provides support for [FairPlay Streaming]. This guide is going to cover the steps to configure a source description with a [EZ DRM] FairPlay stream.

## Table of Contents

* [Creating a custom EZDRM Integration]
* [Registering the custom integration through a factory]
* [Creating Source Description with DRM Configuration]
* [Summary]

## Creating a custom EZDRM Integration

Implement the  `ContentProtectionIntegration` protocol to handle the certificate and license requests and reponses.

```swift
class EzdrmDRMIntegration: ContentProtectionIntegration {
    static let integrationID = "EzdrmDRMIntegration"

    func onExtractFairplayContentId(skdUrl: String, callback: ExtractContentIdCallback) {
        let arr = skdUrl.components(separatedBy: ";")
        let skd = arr[arr.count - 1]
        callback.respond(contentID: skd.data(using: .utf8))
    }

    func onCertificateRequest(request: CertificateRequest, callback: CertificateRequestCallback) {
        callback.request(request: request)
    }

    func onCertificateResponse(response: CertificateResponse, callback: CertificateResponseCallback) {
        callback.respond(certificate: response.body)
    }

    func onLicenseRequest(request: LicenseRequest, callback: LicenseRequestCallback) {
        callback.request(request: request)
    }

    func onLicenseResponse(response: LicenseResponse, callback: LicenseResponseCallback) {
        callback.respond(license: response.body)
    }
}
```

Depending on the DRM integration requirements, you could customize the requests and responses:

```swift

    ...

    func onLicenseRequest(request: LicenseRequest, callback: LicenseRequestCallback) {
        guard let serviceUrl = URL(string: LAURL) else {
            fatalError("'\(LAURL)' is not a valid URL")
        }
        var urlRequest = URLRequest(url: serviceUrl)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = request.body
        urlRequest.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let data = data {
                callback.respond(license: data)
            } else {
                callback.error(error: error!)
            }
        }.resume()
    }

    ...

```

## Registering the custom integration through a factory

Implement the `ContentProtectionIntegrationFactory` protocol to help build the custom integration.

```swift
class EzdrmDRMIntegrationFactory: ContentProtectionIntegrationFactory {
    func build(configuration: DRMConfiguration) -> ContentProtectionIntegration {
        return EzdrmDRMIntegration()
    }
}
```

And register the integration with the following API method:

```swift
let factory = EzdrmDRMIntegrationFactory()
THEOplayer.registerContentProtectionIntegration(integrationId: EzdrmDRMIntegration.integrationID, keySystem: .FAIRPLAY, integrationFactory: factory)
```

Once the integration is registered, it can be used for all `TypedSource` objects for the remainder of the application runtime.

## Creating Source Description with DRM Configuration

`TypedSource` will be used just as [THEO Basic Playback] except that the `FairPlayDRMConfiguration` with a custom integration will be passed as the `drm` property.

```swift
class PlayerViewController: UIViewController {

    ...

    private var source: SourceDescription {
        let ezdrmDrmConfig = FairPlayDRMConfiguration(
            customIntegrationId: EzdrmDRMIntegration.integrationID,
            licenseAcquisitionURL: licenseUrl,
            certificateURL: certificateUrl
        )

        let typedSource = TypedSource(
            src: videoUrl,
            type: mimeType,
            drm: ezdrmDrmConfig
        )

        return SourceDescription(source: typedSource)
    }

    ...
}
```

## Summary

Source description with DRM stream has been created successfully. When the `source` property is invoked, the DRM source description will be returned and then played by THEOplayer.

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[Creating EZDRM Configuration]: #Creating-a-custom-EZDRM-Integration
[Registering the custom integration through a factory]: #Registering-the-custom-integration-through-a-factory
[Creating Source Description with DRM Configuration]: #Creating-Source-Description-with-DRM-Configuration
[Summary]: #Summary

[//]: # (Links and Guides reference)
[THEO Basic Playback]: ../Basic-Playback
[FairPlay Streaming]: https://developer.apple.com/streaming/fps/
[EZ DRM]: https://www.ezdrm.com/
[THEO Docs]: https://docs.portal.theoplayer.com/

[//]: # (Project files reference)
[PlayerViewController.swift]: ../../DRM_Playback/PlayerViewController.swift
