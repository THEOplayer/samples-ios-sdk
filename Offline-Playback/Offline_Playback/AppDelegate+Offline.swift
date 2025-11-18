//
//  AppDelegate.swift
//  Offline_Playback
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

import UIKit
import THEOplayerSDK
import OSLog

@UIApplicationMain
class AppDelegateOffline: AppDelegate {
    override class var ROOT_VC_CLASS: UIViewController.Type { OfflineViewController.self }

    var offlineViewController: OfflineViewController? {
        return (self.window?.rootViewController as? UINavigationController)?.viewControllers.first as? OfflineViewController
    }
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        self.registerDRM()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func registerDRM() {
        let factory = AxinomDRMIntegrationFactory()
        THEOplayer.registerContentProtectionIntegration(integrationId: AxinomDRMIntegration.integrationID, keySystem: .FAIRPLAY, integrationFactory: factory)
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        // Remove all DRM license renew timers
        self.offlineViewController?.viewModel.terminateDrmLicenseRenewTimers()
    }

    override func applicationWillEnterForeground(_ application: UIApplication) {
        // Restore all DRM license renew timers
        self.offlineViewController?.viewModel.restoreDrmLicenseRenewTimers()
    }
}
