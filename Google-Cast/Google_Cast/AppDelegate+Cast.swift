//
//  AppDelegate+Cast.swift
//  Google_Cast
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

import UIKit
import THEOplayerGoogleCastIntegration
import GoogleCast

@UIApplicationMain
class AppDelegateCast: AppDelegate {
    override class var ROOT_VC_CLASS: UIViewController.Type { PlayerViewControllerCast.self }

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        CastIntegrationHelper.setGCKCastContextSharedInstanceWithDefaultCastOptions()
        
          // Or pass custom configuration to set a different appId or other options. Don't forget to replace the _googlecast._tcp value in Info.plist too.

//        let discoveryCriteria = GCKDiscoveryCriteria(applicationID: "B49B6A80")
//        let castOptions = GCKCastOptions(discoveryCriteria: discoveryCriteria)
//        castOptions.physicalVolumeButtonsWillControlDeviceVolume = true
//        castOptions.suspendSessionsWhenBackgrounded = false
//        
//        CastIntegrationHelper.setGCKCastContextSharedInstance(with: castOptions)

        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
