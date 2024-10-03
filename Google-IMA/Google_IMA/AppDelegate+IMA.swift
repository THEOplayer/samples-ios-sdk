//
//  AppDelegate+IMA.swift
//  Google_IMA
//
//  Copyright © 2024 THEOPlayer. All rights reserved.
//

import Foundation

@UIApplicationMain
class AppDelegateIMA: AppDelegate {
    override class var ROOT_VC_CLASS: PlayerViewController.Type { PlayerViewControllerIMA.self }
}
