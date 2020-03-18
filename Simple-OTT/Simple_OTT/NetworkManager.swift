//
//  NetworkManager.swift
//  Simple_OTT
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

import os.log
// Implemented using ReachabilitySwift
import Reachability

// MARK: - NetworkManagerDelegate declaration

protocol NetworkManagerDelegate: class {
    func onWifiConnectionChanged(isConnected: Bool)
}

// MARK: - NetworkManager declaration

class NetworkManager {

    // MARK: - Private properties

    private var reachability : Reachability!
    private var delegates: [NetworkManagerDelegate] = [NetworkManagerDelegate]()

    // MARK: - Public properties

    // Static shared instance to be used by all user
    static let shared = NetworkManager()

    var isWifiConnected: Bool {
        return reachability.connection == .wifi
    }
    var wifiOnlyDownload: Bool = false {
        didSet {
            UserDefaults.standard.set(wifiOnlyDownload, forKey: "wifiOnlyDownload")
        }
    }

    // MARK: - Class life cycle

    // Ensure the init() can only be used by the shared instance
    fileprivate init() {
        setupReachability()
        setupUserDefaults()
    }

    // MARK: - Retrieve setting from UserDefaults

    private func setupUserDefaults() {
        if let bool = UserDefaults.standard.object(forKey: "wifiOnlyDownload") as? Bool {
            os_log("Persisted wifiOnlyDownload: %@", bool ? "true" : "false")
            wifiOnlyDownload = bool
        } else {
            UserDefaults.standard.set(wifiOnlyDownload, forKey: "wifiOnlyDownload")
        }
    }

    // MARK: - Function to add and remove NetworkManagerDelegate

    func addDelegate(delegate: NetworkManagerDelegate) {
        delegates.append(delegate)
    }

    func removeDelegate(delegate: NetworkManagerDelegate) {
        delegates = delegates.filter { $0 !== delegate }
    }
}

// MARK: - ReachabilitySwift

extension NetworkManager {
    private func setupReachability() {
        reachability = try! Reachability()
        NotificationCenter.default.addObserver(self, selector:#selector(onReachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        do {
            try self.reachability.startNotifier()
        }
        catch let error {
            os_log("Failed to start reachability notifier: $@", error.localizedDescription)
        }
    }

    @objc private func onReachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        os_log("Connection changed: %@", reachability.connection.description)
        for delegate in delegates {
            delegate.onWifiConnectionChanged(isConnected: reachability.connection == .wifi)
        }
    }
}
