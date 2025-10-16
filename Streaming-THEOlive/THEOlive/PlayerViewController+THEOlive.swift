//
//  PlayerViewController+THEOlive.swift
//  THEOlive
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

import Foundation
import THEOplayerSDK
import THEOplayerTHEOliveIntegration
import OSLog

class PlayerViewControllerTHEOlive: PlayerViewController {
    
    // Dictionary of the THEOlive integration event listeners
    private var theoLiveListeners: [String: EventListener] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.theoLiveListeners["error"] = self.theoplayer.theoLive?.addEventListener(type: THEOliveEventTypes.ERROR, listener: { [weak self] event in self?.onTheoLiveError(event: event) })
        self.theoLiveListeners["distribution_load_start"] = self.theoplayer.theoLive?.addEventListener(type: THEOliveEventTypes.DISTRIBUTION_LOAD_START, listener: { [weak self] event in self?.onDistributionLoadStart(event: event) })
        self.theoLiveListeners["distribution_offline"] = self.theoplayer.theoLive?.addEventListener(type: THEOliveEventTypes.DISTRIBUTION_OFFLINE, listener: { [weak self] event in self?.onDistributionOffline(event: event) })
        self.theoLiveListeners["endpoint_loaded"] = self.theoplayer.theoLive?.addEventListener(type: THEOliveEventTypes.ENDPOINT_LOADED, listener: { [weak self] event in self?.onEndpointLoaded(event: event) })
        self.theoLiveListeners["intent_to_fallback"] = self.theoplayer.theoLive?.addEventListener(type: THEOliveEventTypes.INTENT_TO_FALLBACK, listener: { [weak self] event in self?.onIntentToFallback(event: event) })
        
        // Configure the player's source to initialize the playback
        let theoLiveSource = SourceDescription(source: TheoLiveSource(channelId: "3aa5qylwwk7gijsobayq09yee"))
        self.theoplayer.source = theoLiveSource
    }
    
    private func onTheoLiveError(event: THEOliveErrorEvent) {
        os_log("THEOLIVE_ERROR event, error: %@", event.error)
    }
    private func onDistributionLoadStart(event: DistributionLoadStartEvent) {
        os_log("DISTRIBUTION_LOAD_START event, distributionId: %{public}@", event.distributionId)
    }
    private func onDistributionOffline(event: DistributionOfflineEvent) {
        os_log("DISTRIBUTION_OFFLINE event, distributionId: %{public}@", event.distributionId)
    }
    private func onEndpointLoaded(event: EndpointLoadedEvent) {
        os_log("""
            THEOLIVE_ENDPOINT_LOADED
            hespSrc: %{public}@,
            hlsSrc: %{public}@,
            cdn: %{public}@,
            adSrc: %{public}@,
            weight: %{public}.2f,
            priority: %{public}d
            """,
               event.endpoint.hespSrc ?? "nil",
               event.endpoint.hlsSrc ?? "nil",
               event.endpoint.cdn ?? "nil",
               event.endpoint.adSrc ?? "nil",
               event.endpoint.weight,
               event.endpoint.priority
        )
    }
    private func onIntentToFallback(event: IntentToFallbackEvent) {
        os_log("INTENT_TO_FALLBACK event, reason: %{public}@", event.reason?.message ?? "Unknown reason")
    }
}
