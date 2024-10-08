//
//  AppDelegate+DRM.swift
//  DRM_Playback
//
//  Copyright © 2024 THEOPlayer. All rights reserved.
//

import Foundation
import THEOplayerSDK

@UIApplicationMain
class AppDelegateDRM: AppDelegate {
    override class var ROOT_VC_CLASS: PlayerViewController.Type { PlayerViewControllerDRM.self }

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        self.registerDRM()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func registerDRM() {
        let factory = EzdrmDRMIntegrationFactory()
        THEOplayer.registerContentProtectionIntegration(integrationId: EzdrmDRMIntegration.integrationID, keySystem: .FAIRPLAY, integrationFactory: factory)
    }
}
