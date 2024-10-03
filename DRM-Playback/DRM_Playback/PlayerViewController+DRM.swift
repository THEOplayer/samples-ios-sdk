//
//  PlayerViewController+DRM.swift
//  DRM_Playback
//
//  Copyright © 2024 THEOPlayer. All rights reserved.
//

import THEOplayerSDK

class PlayerViewControllerDRM: PlayerViewController {
    override var typedSource: TypedSource {
        let videoUrl: String = "https://fps.ezdrm.com/demo/video/ezdrm.m3u8"
        let drmConfig: FairPlayDRMConfiguration = .init(
            customIntegrationId: EzdrmDRMIntegration.integrationID,
            licenseAcquisitionURL: "https://fps.ezdrm.com/api/licenses/09cc0377-6dd4-40cb-b09d-b582236e70fe",
            certificateURL: "https://fps.ezdrm.com/demo/video/eleisure.cer"
        )
        let mimeType: String = "application/x-mpegURL"
        return .init(
            src: videoUrl,
            type: mimeType,
            drm: drmConfig
        )
    }

    override var source: SourceDescription {
        // Returns a computed SourceDescription object
        return SourceDescription(
            source: self.typedSource,
            poster: self.posterUrl
        )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the player's source to initialise playback
        self.theoplayer.source = source
    }
}
