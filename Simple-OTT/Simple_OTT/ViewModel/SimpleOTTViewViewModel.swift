//
//  SimpleOTTViewViewModel.swift
//  Simple_OTT
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

import Foundation
import os.log

// MARK: - SimpleOTTViewControllerType declaration

enum SimpleOTTViewControllerType: String {
    case live = "LIVE"
    case ondemand = "ON DEMAND"
    case offline = "OFFLINE"
    case settings = "SETTINGS"
}

// MARK: - SimpleOTTViewViewModel declaration

class SimpleOTTViewViewModel {

    // MARK: - Private properties

    private var jsonConfig: JSONConfig? = nil

    // MARK: - Public properties

    var contentTableViewVMs: [ContentTableViewViewModel] = [ContentTableViewViewModel]()
    var settingViewVM = SettingsViewViewModel(type: .settings)
    var tabNames: [String] = [String]()

    // MARK: - Class life cycle

    init() {
        if let file = Bundle.main.url(forResource: "Config", withExtension: "json") {
            do {
                jsonConfig = try JSONDecoder().decode(JSONConfig.self, from: try Data(contentsOf: file))
                processJsonConfig()

                // Set tab names
                tabNames = contentTableViewVMs.map{$0.name}
                tabNames.append(SimpleOTTViewControllerType.settings.rawValue)
            } catch {
                fatalError("Failed to parse JSONConfig.json")
            }
        } else {
            fatalError("JSONConfig.json is not found")
        }
    }

    // MARK: - Process JSON config file and instantiate VidwModel objects

    private func processJsonConfig() {
        if let jsonConfig = jsonConfig {
            contentTableViewVMs.append(ContentTableViewViewModel(type: .live, contents: jsonConfig.config.live.channels))
            contentTableViewVMs.append(ContentTableViewViewModel(type: .ondemand, contents: jsonConfig.config.onDemand.vods))
            contentTableViewVMs.append(ContentTableViewViewModel(type: .offline, contents: jsonConfig.config.offline.vods))
        }
    }
}
