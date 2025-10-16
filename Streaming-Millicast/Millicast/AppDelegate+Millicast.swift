//
//  AppDelegate+Millicast.swift
//  Millicast
//
//  Copyright © 2025 Dolby OptiView. All rights reserved.
//

import Foundation
import UIKit

@UIApplicationMain
class AppDelegateMillicast: AppDelegate {
    override class var ROOT_VC_CLASS: UIViewController.Type { PlayerViewControllerMillicast.self }
}
