//
//  AppDelegate+Basic.swift
//  Basic_Playback
//
//  Copyright © 2024 THEOPlayer. All rights reserved.
//

import Foundation

@UIApplicationMain
class AppDelegateBasic: AppDelegate {
    override class var ROOT_VC_CLASS: PlayerViewController.Type { PlayerViewControllerBasic.self }
}
