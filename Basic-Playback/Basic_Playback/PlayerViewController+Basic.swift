//
//  PlayerViewController+Basic.swift
//  Basic_Playback
//
//  Copyright © 2024 THEOPlayer. All rights reserved.
//

import Foundation
import THEOplayerSDK
// If you would like to playback THEOlive Sources, make sure to import this.
import THEOplayerTHEOliveIntegration
// If you would like to playback Millicast Sources, make sure to import this.
import THEOplayerMillicastIntegration

class PlayerViewControllerBasic: PlayerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the player's source to initialise playback
        self.theoplayer.source = self.source
    }
}
