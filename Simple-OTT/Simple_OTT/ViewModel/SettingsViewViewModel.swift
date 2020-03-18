//
//  SettingsViewViewModel.swift
//  Simple_OTT
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

import Foundation
import THEOplayerSDK

// MARK: - SettingsViewViewModel declaration

class SettingsViewViewModel {

    // MARK: - Public properties

    let type: SimpleOTTViewControllerType
    let name: String
    var wifiOnlyDownload: Bool = NetworkManager.shared.wifiOnlyDownload {
        didSet {
            NetworkManager.shared.wifiOnlyDownload = wifiOnlyDownload
            if wifiOnlyDownload {
                for task in THEOplayer.cache.tasks {
                    if task.status == .loading {
                        task.pause()
                    }
                }
            }
        }
    }

    // MARK: - Class life cycle

    init(type: SimpleOTTViewControllerType) {
        self.type = type
        self.name = type.rawValue
    }

    // MARK: - Function to remove cached tasks

    func clearAllDownloads() {
        for task in THEOplayer.cache.tasks {
            task.remove()
        }
    }
}
