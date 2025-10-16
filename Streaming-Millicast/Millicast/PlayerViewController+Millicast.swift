//
//  PlayerViewController+Millicast.swift
//  Millicast
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

import Foundation
import THEOplayerSDK
import THEOplayerMillicastIntegration
import OSLog

class PlayerViewControllerMillicast: PlayerViewController {
    
    // Dictionary of the Millicast integration event listeners
    private var millicastListeners: [String: EventListener] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.millicastListeners["error"] = self.theoplayer.millicast?.addEventListener(type: MillicastEventTypes.ERROR, listener: { [weak self] event in self?.onMillicastError(event: event) })
        
        // Configure the player's source to initialize the playback
        let millicastSource = SourceDescription(source: MillicastSource(src: "multiview", streamAccountId: "k9Mwad"))
        self.theoplayer.source = millicastSource
    }
    
    private func onMillicastError(event: MillicastErrorEvent) {
        os_log("MILLICAST_ERROR event, error: %@", event.error)
    }
}
