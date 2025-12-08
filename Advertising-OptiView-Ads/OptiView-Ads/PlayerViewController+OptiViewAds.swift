//
//  PlayerViewController+OptiViewAds.swift
//  OptiViewAds
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

import Foundation
import THEOplayerSDK
import THEOplayerTHEOadsIntegration
import OSLog

class PlayerViewControllerOptiViewAds: PlayerViewController {
    
    // Dictionary of the OptiView Ads integration event listeners
    private var theoAdsListeners: [String: EventListener] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.theoAdsListeners["add_interstitial"] = self.theoplayer.ads.addEventListener(type: THEOadsEventTypes.ADD_INTERSTITIAL, listener: { [weak self] event in self?.onAddInterstitial(event: event) })
        self.theoAdsListeners["interstitial_begin"] = self.theoplayer.ads.addEventListener(type: THEOadsEventTypes.INTERSTITIAL_BEGIN, listener: { [weak self] event in self?.onInterstitialBegin(event: event) })
        self.theoAdsListeners["interstitial_end"] = self.theoplayer.ads.addEventListener(type: THEOadsEventTypes.INTERSTITIAL_END, listener: { [weak self] event in self?.onInterstitialEnd(event: event) })
        self.theoAdsListeners["interstitial_error"] = self.theoplayer.ads.addEventListener(type: THEOadsEventTypes.INTERSTITIAL_ERROR, listener: { [weak self] event in self?.onInterstitialError(event: event) })
        self.theoAdsListeners["interstitial_update"] = self.theoplayer.ads.addEventListener(type: THEOadsEventTypes.INTERSTITIAL_UPDATE, listener: { [weak self] event in self?.onInterstitialUpdate(event: event) })
        
        // Configure the player's source to initialize the playback
        let source = "PATH-TO-SIGNALING-SERVER/hls/MANIFEST-URI"
        let typedSource = TypedSource(
            src: source,
            type: "application/x-mpegurl",
            hlsDateRange: true
        )
        
        let theoad = THEOAdDescription(
            networkCode: "NETWORK-CODE",
            customAssetKey: "CUSTOM-ASSET-KEY"
        )
        
        let sourceDescription = SourceDescription(source: typedSource, ads: [theoad])
        self.theoplayer.source = sourceDescription
    }
    
    private func onAddInterstitial(event: AddInterstitialEvent) {
        os_log("ADD_INTERSTITIAL event: id=%{public}@, startTime=%{public}.2f, duration=%{public}.2f", event.interstitial.id, event.interstitial.startTime, event.interstitial.duration!)
    }
    private func onInterstitialBegin(event: InterstitialBeginEvent) {
        os_log("INTERSTITIAL_BEGIN, interstitial id: %{public}@, startTime: %{public}.2f", event.interstitial.id, event.interstitial.startTime)
    }
    private func onInterstitialEnd(event: InterstitialEndEvent) {
        os_log("INTERSTITIAL_END, interstitial id: %{public}@, startTime: %{public}.2f", event.interstitial.id, event.interstitial.startTime)
    }
    private func onInterstitialError(event: InterstitialErrorEvent) {
        os_log("INTERSTITIAL_ERROR, error: %{public}@", event.message!)
    }
    private func onInterstitialUpdate(event: InterstitialUpdateEvent) {
        os_log("INTERSTITIAL_UPDATE, interstitial id: %{public}@, startTime: %{public}.2f", event.interstitial.id, event.interstitial.startTime)
    }
}
