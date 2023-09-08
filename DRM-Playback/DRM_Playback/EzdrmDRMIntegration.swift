//
//  EzdrmDRMIntegration.swift
//  THEOplayer_iOS_SDK_Sandbox_Swift
//
//  Created by Mohamed on 07/01/2021.
//  Copyright © 2021 THEOplayer. All rights reserved.
//

import Foundation
import THEOplayerSDK

class EzdrmDRMIntegration: ContentProtectionIntegration {
    static let integrationID = "EzdrmDRMIntegration"
    let CERTURL = "https://fps.ezdrm.com/demo/video/eleisure.cer"
    let LAURL = "https://fps.ezdrm.com/api/licenses/09cc0377-6dd4-40cb-b09d-b582236e70fe"

    func onExtractFairplayContentId(skdUrl: String, callback: ExtractContentIdCallback) {
        let arr = skdUrl.components(separatedBy: ";")
        let skd = arr[arr.count - 1]
        callback.respond(contentID: skd.data(using: .utf8))
    }

    func onCertificateRequest(request: CertificateRequest, callback: CertificateRequestCallback) {
        let requestString = String(data: try! JSONEncoder().encode(request), encoding: .utf8)!
        print("<- \(#function): \(requestString)")
        var newRequest = URLRequest(url: URL(string: CERTURL)!)
        newRequest.httpMethod = "GET"
        URLSession.shared.dataTask(with: newRequest) { data, response, error in
            callback.respond(certificate: data!)
        }
        .resume()

        // alternatively, you could resolve the original request
        // callback.request(request: request)
    }

    func onCertificateResponse(response: CertificateResponse, callback: CertificateResponseCallback) {
        let responseString = String(data: try! JSONEncoder().encode(response), encoding: .utf8)!
        print("* \(#function): \(responseString)")
        callback.respond(certificate: response.body)
    }

    func onLicenseRequest(request: LicenseRequest, callback: LicenseRequestCallback) {
        guard let serviceUrl = URL(string: LAURL) else {
            fatalError("'\(LAURL)' is not a valid URL")
        }
        var urlRequest = URLRequest(url: serviceUrl)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = request.body
        //print("onLicenseRequest REQ BODY: ", String(data: request.body!, encoding: .utf8))
        urlRequest.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let data = data {
                print("onLicenseRequest REQ DATA: ", String(data: data, encoding: .utf8))
                callback.respond(license: data)
            } else {
                callback.error(error: error!)
            }
        }.resume()

        // alternatively, you could resolve the original request
        // callback.request(request: request)
    }

    func onLicenseResponse(response: LicenseResponse, callback: LicenseResponseCallback) {
        print("onLicenseRESP resp DATA: ", response.body)
        callback.respond(license: response.body)
    }
}

class EzdrmDRMIntegrationFactory: ContentProtectionIntegrationFactory {
    func build(configuration: DRMConfiguration) -> ContentProtectionIntegration {
        return EzdrmDRMIntegration()
    }
}
