# THEO Knowledge Base - Xcode Setup

The following steps show how to install Xcode and sign in with Apple id on macOS. At the time of this writing, the latest version of Xcode is 11.3.1 and this guide is written based on this version of Xcode.

## Table of Contents

* [Apple ID]
* [Install Xcode]
* [Sign in]
* [Summary]

## Apple ID

Apple ID will be needed to sign in to App Store and download Xcode, see [Apple ID Page] for detail on how to create one.

The same Apple ID can be used to sign in to Xcode as a Apple Developer and enroll to the [Apple Developer Program]. While an enrolled Apple Developer account is not needed for the purpose of this guide, some of Xcode feature (for example app distribution) will be restricted which might be need in other **`THEOplayer iOS Reference Apps`**. Please check on the link for more detail.

## Install Xcode

Launch **`App Store`** from **`Launchpad`** and click `sign in` at the bottom left and provide Apple ID and password to sign in.

!["App Store Sign-in"][01]

Search for **`Xcode`**, install it and open after installation is completed.

!["XCode In App Store"][02]

The following is the launch screen of Xcode. It has the current Xcode version string printed. New project and existing project can be created and opened from here respectively.

!["Xcode Welcome Screen"][03]

## Sign in

Once Xcode is installed, sign in with an Apple ID.

Click on `Xcode` from the status bar and select `Preferences`.

!["Xcode Preference"][04]

Add an `Apple ID` account from the `Accounts` tab as shown below.

!["Xcode Sign-in With Apple ID"][05]

Sign in with Apple ID and password.

!["Xcode Input Apple ID Username and Password"][06]

The `Accounts` tab should look like this on succeeded.

!["Xcode Accounts Screen"][07]

## Summary

Xcode is now successfully installed and configured. The next guide covering how to create a simple iOS application can be found here: [THEO Knowledge Base - Simple Application].

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[Apple ID]: #Apple-ID
[Install Xcode]: #Install-Xcode
[Sign in]: #Sign-in
[Summary]: #Summary

[//]: # (Links and Guides reference)
[THEO Knowledge Base - Simple Application]: ../knowledgebase-simple-application/README.md
[Apple ID Page]: https://support.apple.com/en-gb/HT204316
[Apple Developer Program]: https://developer.apple.com/support/compare-memberships/
[THEO Docs]: https://docs.portal.theoplayer.com/

[//]: # (Images references)
[01]: Images/appStoreSignIn.png "App Store Sign-in"
[02]: Images/xcodeInAppStore.png "XCode In App Store"
[03]: Images/xcodeWelcomeScreen.png "Xcode Welcome Screen"
[04]: Images/xcodePreference.png "Xcode Preference"
[05]: Images/xcodeSignInWithAppleID.png "Xcode Sign-in With Apple ID"
[06]: Images/xcodeInputAppleIDUsernameandPassword.png "Xcode Input Apple ID Username and Password"
[07]: Images/xcodeAccountsScreen.png "Xcode Accounts Screen"
