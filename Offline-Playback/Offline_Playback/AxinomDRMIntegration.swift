//
//  AxinomDRMIntegration.swift
//  Offline_Playback
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

import Foundation
import THEOplayerSDK

class AxinomDRMIntegration: ContentProtectionIntegration {
    static let integrationID = "AxinomDRM"
    let configuration: DRMConfiguration

    public init(configuration: DRMConfiguration) {
        self.configuration = configuration
    }

    func onExtractFairplayContentId(skdUrl: String, callback: ExtractContentIdCallback) {
        let skd = URL(string: skdUrl)?.host ?? skdUrl
        callback.respond(contentID: skd.data(using: .utf8))
    }

    func onCertificateRequest(request: CertificateRequest, callback: CertificateRequestCallback) {
        callback.request(request: request)
    }

    func onCertificateResponse(response: CertificateResponse, callback: CertificateResponseCallback) {
        callback.respond(certificate: response.body)
    }

    func onLicenseRequest(request: LicenseRequest, callback: LicenseRequestCallback) {
        if let headers = configuration.headers {
            request.headers = headers.reduce([String: String]()) { acc, dict in
                acc.merging(dict) { $1 }
            }
        }

        request.headers["X-AxDRM-Message"] = configuration.integrationParameters!["token"] as? String
        callback.request(request: request)
    }

    func onLicenseResponse(response: LicenseResponse, callback: LicenseResponseCallback) {
        callback.respond(license: response.body)
    }
}

class AxinomDRMIntegrationFactory: ContentProtectionIntegrationFactory {
    func build(configuration: DRMConfiguration) -> ContentProtectionIntegration {
        return AxinomDRMIntegration(configuration: configuration)
    }
}
