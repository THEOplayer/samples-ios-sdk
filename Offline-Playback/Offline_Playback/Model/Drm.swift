//
//  Drm.swift
//  Offline_Playback
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

// MARK: - DrmType enumeration declaration

enum DrmType: Int {
    case ezDrm
    case uplynk
}

// MARK: - Drm declaration

struct Drm {
    var type: DrmType
    var licenseUrl: String
    var certificateUrl: String
}
