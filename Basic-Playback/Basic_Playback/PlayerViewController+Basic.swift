//
//  PlayerViewController+Basic.swift
//  Basic_Playback
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

import Foundation

class PlayerViewControllerBasic: PlayerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the player's source to initialise playback
        self.theoplayer.source = self.source
    }
}
