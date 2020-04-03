# THEOplayer How To's - Setup Reference Application

The following guide explains the various project configurations and code needed prior to the **`THEOplayer SDK`** integration.

## Table of Content

* [Minimum Development Target]
* [Hide Status Bar]
* [Disable iPad Slide Over and Split View]
* [iOS 13 UIScene]
* [Theme]
* [Navigation Controller and Root View Controller]
* [Splash Screen]
* [Summary]

## Minimum Development Target

The official minimum development target supported by THEOplayer is **`iSO 11`**, therefore configure the project settings to reflect this.

!["Minimum Development Target"][01]

## Hide Status Bar

Check `Hide status bar` as follow.

!["Hide Status Bar"][02]

Click on `Info.plist`, hover over one of the key item under `Information Property List` and click on plus button that appears at the end of the item. Input or search for `View controller-based status bar appearance`, ensure the key type to be `Boolean` and set the value to `NO`.

!["Set View Controller Status Bar Appearance"][03]

## Disable iPad Slide Over and Split View

Slide over and split view are not needed in reference apps. According to [Apple Document]:

> To opt out of being eligible to participate in Slide Over and Split View, add the `UIRequiresFullScreen` key to your Xcode project’s `Info.plist` file and apply the Boolean value `YES`.

The same can achieved from project setting, check the `Requires full screen` checkbox below `Hide status bar`.

!["Requires Full Screen"][04]

## iOS 13 UIScene

The [Minimum Development Target] setting will cause build failure. This is because iOS 13 introduced `UIScene` to manage App's UI lifecycle which is not backward compatible with iOS 12 nor iOS 11. The next few steps will work around this problem by removing `SceneDelegate` and restoring `AppDelegate`.

!["Compile Error"][05]

Delete `SceneDelegate` from the project and select `Move to Trash`.

!["Remove Scene Delegate"][06]

Open `AppDelegate` and remove the highlighted code block.

!["Remove Scene Code"][07]

Add `var window: UIWindow?` in `AppDelegate` as below:

!["Add Window Var"][08]

Delete `Application Scene Manifest` in `info.plist`.

!["Delete Scene Manifest"][09]

Rebuild again, all problems should be fixed now.

!["Build Fixed"][10]

## Theme

A list of `Font` and `Colour` used in the reference app are defined in [Theme.swift] as extensions to `UIFont` and `UIColour` respectively. For example:

```swift
    extension UIFont {

        ...

        static var theoText: UIFont {
            return UIFont.systemFont(ofSize: 14)
        }

        ...
    }

    extension UIColor {

        ...

        static var theoLightningYellow: UIColor {
            return UIColor(displayP3Red: 255 / 255, green: 199 / 255, blue: 19 / 255, alpha: 1.0)
        }
    }
```

## Navigation Controller and Root View Controller

[UINavigationController] is used across all reference app to manage navigation between different view controllers.

Navigation controller is instantiated in [AppDelegate.swift] as follow, it is created and customised by `createNavigationController()` and is used as the root view controller of the `window`. [PlayerViewController.swift] on the other hand, is the root view controller of the navigation controller serving as the primary view controller of the application.

```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        ...

        let playerViewController = PlayerViewController()
        let navigationController = createNavigationController(rootViewController: playerViewController)

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        ...
    }
```

The code snippet below is the declaration of `createNavigationController()`, highlights of the customisation made as follow. See inline comment in [AppDelegate.swift] for more detail.

* Disabled wiping navigation to avoid unexpected navigation.
* Set navigation bar title with Xcode project bundle name.
* Removed navigation bar highlight.
* Use theme colour in back arrow.

```swift
    private func createNavigationController(rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)

        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.isTranslucent = true
        navigationController.navigationBar.tintColor = .theoLightningYellow
        navigationController.navigationBar.titleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.theoWhite ]
        navigationController.navigationBar.topItem?.title = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String

        return navigationController
    }
```

## Splash Screen

The section provides a brief description on how to change the splash screen. This is **optional** as it does not affect any functionality of the reference app.

By default, Xcode will create a empty splash screen with a simple white screen. Select `LaunchScreen.storyboard` from Xcode to open it with interface builder. Highlight the `view` and set the desire `background` colour.

!["Splash Screen Background"][11]

Add a `UIImageView` to the center of the view and set the desire image in `Image View` section under the `Attributes Inspector` tab.

!["Splash Screen Image View"][12]

Apply constraints to the image view as shown below.

!["Splash Screen Constraints"][13]

## Summary

The reference application project is now ready for the `THEOplayer SDK` integration which will be covered in the [THEOplayer How To's - THEOplayer iOS SDK Integration] guide.

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[Minimum Development Target]: #Minimum-Development-Target
[Hide Status Bar]: #Hide-Status-Bar
[Disable iPad Slide Over and Split View]: #Disable-iPad-Slide-Over-and-Split-View
[iOS 13 UIScene]: #iOS-13-UIScene
[Theme]: #Theme
[Navigation Controller and Root View Controller]: #Navigation-Controller-and-Root-View-Controller
[Splash Screen]: #Splash-Screen
[Summary]: #Summary

[//]: # (Links and Guides reference)
[THEOplayer How To's - THEOplayer iOS SDK Integration]: ../howto-theoplayer-ios-sdk-integration/README.md
[Apple Document]: https://developer.apple.com/library/archive/documentation/WindowsViews/Conceptual/AdoptingMultitaskingOniPad/index.html
[UINavigationController]: https://developer.apple.com/documentation/uikit/uinavigationcontroller
[THEO Docs]: https://docs.portal.theoplayer.com/

[//]: # (Project files reference)
[Theme.swift]: ../../Basic_Playback/Theme.swift
[AppDelegate.swift]: ../../Basic_Playback/AppDelegate.swift
[PlayerViewController.swift]: ../../Basic_Playback/PlayerViewController.swift

[//]: # (Images references)
[01]: Images/minimumDevelopmentTarget.png "Minimum Development Target"
[02]: Images/hideStatusBar.png "Hide Status Bar"
[03]: Images/statusBarAppearance.png "Set View Controller Status Bar Appearance"
[04]: Images/requiresFullScreen.png "Requires Full Screen"
[05]: Images/compileError.png "Compile Error"
[06]: Images/removeSceneDelegate.png "Remove Scene Delegate"
[07]: Images/removeSceneCode.png "Remove Scene Code"
[08]: Images/addWindowVar.png "Add Window Var"
[09]: Images/deleteSceneManifest.png "Delete Scene Manifest"
[10]: Images/buildFixed.png "Build Fixed"
[11]: Images/splashScreenBackground.png "Splash Screen Background"
[12]: Images/splashScreenImageView.png "Splash Screen Image View"
[13]: Images/splashScreenConstraints.png "Splash Screen Constraints"
