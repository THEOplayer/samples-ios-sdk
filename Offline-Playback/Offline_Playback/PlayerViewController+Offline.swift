//
//  PlayerViewController+Offline.swift
//  Offline_Playback
//
//  Created by Raffi on 03/12/2024.
//  Copyright © 2024 THEOPlayer. All rights reserved.
//

import THEOplayerSDK

class PlayerViewControllerOffline: PlayerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the player's source to initialise playback
        self.theoplayer.source = self.source
    }
}
