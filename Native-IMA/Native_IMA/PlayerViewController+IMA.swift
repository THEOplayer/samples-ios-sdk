//
//  PlayerViewController+IMA.swift
//  Native_IMA
//
//  Copyright © 2024 THEOPlayer. All rights reserved.
//

import THEOplayerSDK
import THEOplayerGoogleIMAIntegration

class PlayerViewControllerIMA: PlayerViewController {
    override var source: SourceDescription {
        // IMA ad tag URL
        let adTagUrl: String = "https://pubads.g.doubleclick.net/gampad/ads?slotname=/124319096/external/ad_rule_samples&sz=640x480&ciu_szs=300x250&cust_params=deployment%3Ddevsite%26sample_ar%3Dpreonly&url=https://developers.google.com/interactive-media-ads/docs/sdks/android/client-side/tags&unviewed_position_start=1&output=xml_vast3&impl=s&env=vp&gdfp_req=1&ad_rule=0&vad_type=linear&vpos=preroll&pod=1&ppos=1&lip=true&min_ad_duration=0&max_ad_duration=30000&vrid=5776&video_doc_id=short_onecue&cmsid=496&kfa=0&tfcd=0"

        // The AdDescription object that defines the IMA ad to be played.
        let adDescription: GoogleImaAdDescription = GoogleImaAdDescription(src: adTagUrl)

        // Returns a computed SourceDescription object
        return SourceDescription(
            source: self.typedSource,
            ads: [adDescription],
            poster: self.posterUrl
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Configure the player's source to initialise playback.
        // If the source contains an AdDescription, then it must be called when viewDidAppear is called (or later) so that the IMAAdDisplayContainer is ready.
        // If the IMAAdDisplayContainer is not ready yet, then the IMAAdsRequest will fail.
        if self.theoplayer.source == nil {
            self.theoplayer.source = source
        }
    }

    override func setupIntegrations() {
        let imaIntegration: THEOplayerSDK.Integration = GoogleIMAIntegrationFactory.createIntegration(on: self.theoplayer)
        self.theoplayer.addIntegration(imaIntegration)
    }
}
