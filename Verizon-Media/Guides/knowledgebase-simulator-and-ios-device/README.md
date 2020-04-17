# THEO Knowledge Base - Simulator And iOS Device

iOS application can be executed on simulator or on a iOS device. This guide demonstrates both ways with the simple application created in [THEO Knowledge Base - Simple Application].

Note that while simulator is great for development and quick testing, it is not the same as executing on actual iOS devices. See [Differences between simulated and physical devices] from Apple document for more detail.

## Table of Contents

* [Simulator]
  * [Simulator for older iOS]
* [iOS Device]
  * [Sideloading]

## Simulator

Click on the scheme list in the XCode IDE as follow:

!["Click On Scheme List"][01]

Select one of available simulators. In this demo, `iPhone 11 Pro Max` (the default) will be used.

!["Simulators"][02]

Click the `Play` button or `Product > Run` from Xcode menu bar or `⌘ + R` to run the Hello World App in the selected simulator.

!["Run Simulator"][03]

A simulator window will be open and the app will be installed and executed automatically.

!["Simulator Output"][04]

### Simulator for older iOS

Older simulators can be installed for backward compatibility testing. Focus on Xcode and go to `Preferences` via `Xcode > Preferences` from the Xcode menu bar or `⌘ + ,`. Navigate to the `Components` tab, select the necessary iSO simulator and click `Check and Install Now`.

!["Install Older Simulators"][05]

After installation is completed, scheme list will be updated with additional simulators.

!["Older Simulators"][06]

## iOS Device

There are various way to deploy app onto iOS device, for example:

* [Sideloading]
* [TestFlight]
* [Firebase]

The following sub-section will only demonstrate how to sideload the **_Hello World App_** to a iOS device. More detail on TestFlight and Firebase can be found from the above links.

### Sideloading

Connect the iOS device to the Mac machine with a USB cable. Open iTunes to check if the device is connected if necessary.

Click on the scheme list in Xcode list and the device should appear under the `Device` section

!["Device"][07]

Select the device.

!["Device Selected"][08]

Click the `Play` button or `Product -> Run` from Xcode menu bar or `⌘ + R` to run the Hello World App in the selected device.

!["Run App On Device"][09]

> Note
>
> Ensure the signed in user owns the **_Organization Identifier_** set in the project or at least set an unique **_Organization Identifier_**, otherwise the build would fail as below:
>
> !["App Identifier Error"][10]

Prompt might appear on the first time. Input macOS user password and click on `Always Allow`.

!["Xcode Permission Check"][11]

Additional security steps are required to sideload to the iOS device if the developer is not trusted on the device, hence the reason run XCode might fail as shown below.

!["App Run Failure"][12]

Unlock the iOS device and access `Settings`. Click on `General` on the left hand side then click on `Device Management`.

!["iOS Device Management"][13]

Click on `Apple Development`.

!["iOS Apple Development"][14]

Check app name and Apple ID displayed and click on `Trust Apple Development: <email>`

!["iOS Trust Developer"][15]

Click `Trust` after double checked the info.

!["iOS Confirm Trust"][16]

Completed. Trusted app can be deleted from the same spot in `Settings` if needed.

!["iOS Developer Trusted"][17]

Perform step 4 again on Xcode to run the **`Hello World App`** on the device.

## Summary

This guide covered how to launch application on simulator and iOS device in depth. Please note that some of THEOplayer features can only be running on physical devices. For example DRM playback, offline stream caching etc.

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[Prerequisites]: #Prerequisites
[Simulator]: #Simulator
[Simulator for older iOS]: #Simulator-for-older-iOS
[iOS Device]: #iOS-Device
[Sideloading]: #Sideloading
[Summary]: #Summary

[//]: # (Links and Guides reference)
[THEO Knowledge Base - Simple Application]: ../knowledgebase-simple-application/README.md
[Differences between simulated and physical devices]: https://help.apple.com/simulator/mac/current/#/devb0244142d
[TestFlight]: https://developer.apple.com/testflight/
[Firebase]: https://firebase.google.com/docs/app-distribution
[THEO Docs]: https://docs.portal.theoplayer.com/

[//]: # (Images references)
[01]: Images/clickOnSchemeList.png "Click On Scheme List"
[02]: Images/simulators.png "Simulators"
[03]: Images/runSimulator.png "Run Simulator"
[04]: Images/simulatorOutput.png "Simulator Output"
[05]: Images/installOlderSimulators.png "Install Older Simulators"
[06]: Images/olderSimulators.png "Older Simulators"
[07]: Images/device.png "Device"
[08]: Images/deviceSelected.png "Device Selected"
[09]: Images/runAppOnDevice.png "Run App On Device"
[10]: Images/appIdentifierError.png "App Identifier Error"
[11]: Images/xcodePermissionCheck.png "Xcode Permission Check"
[12]: Images/appRunFailure.png "App Run Failure"
[13]: Images/iosDeviceManagement.png "iOS Device Management"
[14]: Images/iosAppleDevelopment.png "iOS Apple Development"
[15]: Images/iosTrustDeveloper.png "iOS Trust Developer"
[16]: Images/iosConfirmTrust.png "iOS Confirm Trust"
[17]: Images/iosDeveloperTrusted.png "iOS Developer Trusted"
