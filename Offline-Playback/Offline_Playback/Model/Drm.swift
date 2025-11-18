//
//  Drm.swift
//  Offline_Playback
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

// MARK: - Drm declaration

struct Drm {
    var customIntegrationId: String
    var licenseAcquisitionURL: String
    var certificateURL: String
    var integrationParameters: Dictionary<String, Any>
}
