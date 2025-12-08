//
//  CastLabsDRMIntegration.swift
//  Offline_Playback
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

import Foundation
import THEOplayerSDK

public class CastLabsDRMIntegration: ContentProtectionIntegration {
    public static let integrationID = "CastLabsDRMIntegration"
    static let DEFAULT_CERTIFICATE_URL = "https://lic.drmtoday.com/license-server-fairplay/cert/"
    static let DEFAULT_LICENSE_URL = "https://lic.staging.drmtoday.com/license-server-fairplay/"
    
    let configuration: DRMConfiguration
    private var contentId: String?
    private let customData: String
    
    public init(configuration: DRMConfiguration) {
        self.configuration = configuration
        
        // Build custom data from integration parameters
        let customDataObject: [String: Any] = [
            "userId": configuration.integrationParameters?["userId"] as? String ?? "",
            "sessionId": configuration.integrationParameters?["sessionId"] as? String ?? "",
            "merchant": configuration.integrationParameters?["merchant"] as? String ?? ""
        ]
        
        let customDataJson = try? JSONSerialization.data(withJSONObject: customDataObject, options: [])
        self.customData = customDataJson?.base64EncodedString() ?? ""
    }
    
    public func onCertificateRequest(request: CertificateRequest, callback: CertificateRequestCallback) {
        print("[CastLabs Connector] Certificate Request URL: \(request.url)")
        
        // Add custom data header to certificate request
        request.headers = [
            "x-dt-custom-data": self.customData
        ]
        
        print("[CastLabs Connector] Certificate request headers: \(request.headers)")
        callback.request(request: request)
    }
    
    public func onCertificateResponse(response: CertificateResponse, callback: CertificateResponseCallback) {
        callback.respond(certificate: response.body)
    }
    
    public func onLicenseRequest(request: LicenseRequest, callback: LicenseRequestCallback) {
        print("[CastLabs Connector] licenseRequestUrl: \(request.url)")
        
        // Encode the SPC
        guard let spcData = request.body else {
            callback.error(error: NSError(domain: "CastLabsDRM", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing SPC"]))
            return
        }
        
        // Use the same encoding as CastLabs sample - exclude :?=&+ characters
        let spcBase64 = spcData.base64EncodedString()
        let queryKeyValueString = CharacterSet(charactersIn: ":?=&+").inverted
        let spcEncoded = spcBase64.addingPercentEncoding(withAllowedCharacters: queryKeyValueString) ?? spcBase64
        
        print("[CastLabs Connector] SPC base64: \(spcEncoded)")
        
        // Build request body - add offline parameter for caching support
        var body = "spc=\(spcEncoded)"
        
        // Add offline parameter to URL query and body for persistent license support
        if !request.url.isEmpty, var urlComponents = URLComponents(string: request.url) {
            var queryItems = urlComponents.queryItems ?? []
            queryItems.append(URLQueryItem(name: "offline", value: "true"))
            urlComponents.queryItems = queryItems
            if let updatedUrl = urlComponents.string {
                request.url = updatedUrl
            }
        }
        
        // Also add to body
        body += "&offline=true"
        print("[CastLabs Connector] Offline mode enabled for license request")
        
        request.body = body.data(using: .utf8)
        
        request.headers = [
            "x-dt-custom-data": self.customData,
            "x-dt-auth-token": configuration.integrationParameters?["token"] as? String ?? "",
            "Content-Type": "application/x-www-form-urlencoded",
            "Content-Length": String(request.body?.count ?? 0)
        ]
        
        print("[CastLabs Connector] License request headers: \(request.headers)")
        print("[CastLabs Connector] License request body: \(String(data: request.body!, encoding: .utf8) ?? "nil")")

        callback.request(request: request)
    }
    
    public func onLicenseResponse(response: LicenseResponse, callback: LicenseResponseCallback) {
        print("[CastLabs Connector] License response body (raw): \(String(data: response.body, encoding: .utf8) ?? "nil")")
        print("[CastLabs Connector] License response body (base64): \(response.body.base64EncodedString())")
        
        guard var licenseString = String(data: response.body, encoding: .utf8) else {
            print("[CastLabs Connector] ERROR: Could not decode response body as UTF-8")
            callback.error(error: NSError(domain: "CastLabsDRM", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid license response"]))
            return
        }
        
        print("[CastLabs] License string: \(licenseString)")
        
        // Remove <ckc> tags if present
        if licenseString.hasPrefix("<ckc>") && licenseString.hasSuffix("</ckc>") {
            licenseString = String(licenseString.dropFirst(5).dropLast(6))
            print("[CastLabs Connector] Removed CKC tags, new string: \(licenseString)")
        }
        
        guard let data = Data(base64Encoded: licenseString) else {
            print("[CastLabs Connector] ERROR: Could not decode license as base64")
            callback.error(error: NSError(domain: "CastLabsDRM", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid base64 license"]))
            return
        }
        
        print("[CastLabs Connector] CKC base64: \(data.base64EncodedString())")
        print("[CastLabs Connector] CKC length: \(data.count) bytes")
        
        callback.respond(license: data)
    }
    
    public func onExtractFairplayContentId(skdUrl: String, callback: ExtractContentIdCallback) {
        print("[CastLabs Connector] Extracting contentId from SKD URL: \(skdUrl)")
        
        // For DRMToday, we need to return the content after "skd://"
        // e.g., "skd://drmtoday?keyId=6fbf6d37cf3840c09c99ad8da1dff10b" -> "drmtoday?keyId=6fbf6d37cf3840c09c99ad8da1dff10b"
        var contentId = skdUrl
        if skdUrl.hasPrefix("skd://") {
            contentId = String(skdUrl.dropFirst(6))
        }
        
        self.contentId = contentId
        print("[CastLabs] Extracted contentId: \(contentId)")
        callback.respond(contentID: contentId.data(using: .utf8))
    }
}

public class CastLabsDRMIntegrationFactory: ContentProtectionIntegrationFactory {
    
    public init() {}
    
    public func build(configuration: DRMConfiguration) -> ContentProtectionIntegration {
        return CastLabsDRMIntegration(configuration: configuration)
    }
}
