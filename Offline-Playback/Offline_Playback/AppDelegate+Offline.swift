//
//  AppDelegate.swift
//  Offline_Playback
//
//  Copyright © 2019 THEOPlayer. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegateOffline: AppDelegate {
    override class var ROOT_VC_CLASS: UIViewController.Type { OfflineViewController.self }

    var offlineViewController: OfflineViewController? {
        return (self.window?.rootViewController as? UINavigationController)?.viewControllers.first as? OfflineViewController
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Remove all DRM licnese renew timer
        self.offlineViewController?.viewModel.terminateDrmLicenseRenewTimers()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Retore all DRM licnese renew timer
        self.offlineViewController?.viewModel.restoreDrmLicenseRenewTimers()
    }
}
