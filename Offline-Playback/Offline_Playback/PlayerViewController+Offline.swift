//
//  PlayerViewController+Offline.swift
//  Offline_Playback
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

import THEOplayerSDK

class PlayerViewControllerOffline: PlayerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the player's source to initialize the playback
        self.theoplayer.source = self.source
    }
}
