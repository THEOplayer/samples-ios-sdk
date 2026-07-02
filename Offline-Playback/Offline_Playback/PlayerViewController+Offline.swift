//
//  PlayerViewController+Offline.swift
//  Offline_Playback
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

import THEOplayerSDK
import os.log

class PlayerViewControllerOffline: PlayerViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the player's source to initialize the playback
        // If the source URL matches a cached task, play from cache; otherwise play online.
        let onlineSource = self.source
        let onlineSrc = onlineSource.sources.first?.src
        
        if let cachedTask = THEOplayer.cache.tasks.first(where: { task in
            task.source.sources.first?.src == onlineSrc
        }) {
            os_log("Playing from cache with the previously set caching parameters since the source is cached.")
            self.theoplayer.source = cachedTask.source
        } else {
            os_log("Playing online since the source is not cached.")
            self.theoplayer.source = onlineSource
        }
    }
}
