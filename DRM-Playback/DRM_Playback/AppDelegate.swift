//
//  AppDelegate.swift
//  DRM_Playback
//
//  Copyright © 2019 THEOPlayer. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Initialise window
        window = UIWindow(frame: UIScreen.main.bounds)

        // Initailise PlayerViewController
        let playerViewController = PlayerViewController()
        // Create navigationController and set playerViewController as its root view controller
        let navigationController = createNavigationController(rootViewController: playerViewController)

        // Set window's root view controller
        window?.rootViewController = navigationController
        // Show window
        window?.makeKeyAndVisible()

        return true
    }

    private func createNavigationController(rootViewController: UIViewController) -> UINavigationController {
        // Initailise UINavigationController and set provided UIViewController as root view controller
        let navigationController = UINavigationController(rootViewController: rootViewController)

        // Disable swipe to navigate back
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        // Remove navigationBar default highlight
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.isTranslucent = true
        // Set navigationBar tinit colour
        navigationController.navigationBar.tintColor = .theoLightningYellow
        // Set navigationBar title text colour
        navigationController.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.theoWhite ]
        // Set navigationBar title
        navigationController.navigationBar.topItem?.title = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String

        return navigationController
    }
}
