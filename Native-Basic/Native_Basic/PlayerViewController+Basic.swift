//
//  PlayerViewController+Basic.swift
//  Native_Basic
//
//  Copyright © 2024 THEOPlayer. All rights reserved.
//

import Foundation

class PlayerViewControllerBasic: PlayerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Configure the player's source to initialise playback
        self.theoplayer.source = self.source
    }
}
