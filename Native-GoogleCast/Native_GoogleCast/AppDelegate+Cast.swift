//
//  AppDelegate+Cast.swift
//  Native_GoogleCast
//
//  Copyright © 2024 THEOPlayer. All rights reserved.
//

import UIKit
import THEOplayerGoogleCastIntegration

@UIApplicationMain
class AppDelegateCast: AppDelegate {
    override class var ROOT_VC_CLASS: PlayerViewController.Type { PlayerViewControllerCast.self }

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        CastIntegrationHelper.setGCKCastContextSharedInstanceWithDefaultCastOptions()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
