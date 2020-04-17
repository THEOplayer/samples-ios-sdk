# THEO Knowledge Base - Simple Application

This guide is going to show how to create a simple iOS application.

Checkout [THEO Knowledge Base - Xcode Setup] for guide on how to setup Xcode.

## Table of Contents

* [Create New Project]
* [Implementation]
* [Build Project]
* [Summary]

## Create New Project

Open Xcode and click on `Create a new Xcode project`

!["Create Project"][01]

Xcode provides various project templates for different platform. Select `Single View App` template for iOS and click `Next`.

!["Single View App"][02]

Fill in the options as follows:

* **Product Name**: `helloworld`
* **Organization Name**: Name of your organization
* **Organization Identifier**: This is in reversed domain name notation and will be concatenated with `Product Name` to form `Bundle ID`. The identifier is not connected to any domain but is used to uniquely identify app.
* **Language**: All **_THEOplayer Reference Apps_** are written in Swift
* **User Interface**: All **_THEOplayer Reference Apps_** are developed based on Storyboard/UIKit.
* **Use Core Data**: Uncheck unless it is needed.
* **Include Unit Tests**: Uncheck unless it is needed.
* **Include UI Tests**: Uncheck unless it is needed.

!["Set Project Info"][03]

Click on the `Team` dropdown box and select the Apple User previously signed in. Then click `Next`.

!["Set Project User"][04]

Save project to desire location. Note that, Xcode use Git for source control by default.

!["Save Project"][05]

Xcode IDE will be started on project creation succeeded.

!["New Project Created"][06]

An error prompt will be prompted if author information is not previously configured in Xcode. Click `Fix...`

!["No Author Warning"][07]

Provide `Author Name` and `Author Email`. These info will be used when commit changes to the Git repo using Xcode.

!["Input Author Info"][08]

## Implementation

Click on `Main.storyboard` which will bring up interface builder.

!["Open Main Storyboard"][09]

Click the + button on the top left to access element library

!["Create Label"][10]

Search for `Label` then drag and drop it the view controller. Then click on the `Align` at the bottom of the interface builder to bring up the `Alignment Constraints` popup.

!["Position Label"][11]

Select `Horizontally in Container` and `Vertically in Container` then click `Add 2 Constraints` to keep the label in the center of the view controller.

!["Create Constraints For Label"][12]

Click on the `label` in the view controller and access `Attributes Inspector` on the left.

!["Highlight Label"][13]

Change the word `Label` to `Hello World` in the attribute inspector and press enter to apply the changes.

!["Change Label To Hello World"][14]

## Build Project

From Xcode menu bar, click `Product > Build` or `⌘ + B` to build the project. Progress of the build can be inspected in the progress bar at the top of Xcode.

!["Build Project"][15]

In case of failure or warning, click on the icon in Xcode progress bar or the triangular warning button to navigate to the `Issue Navigator`. Address the issue and rebuild.

!["Project Build Failure"][16]

Build result will also be reported in the popup:

!["Build Result Popup"][17]

## Summary

A simple iOS application has been created successfully. The next guide will cover how to launch the simple application on simulator and actual iOS device [THEO Knowledge Base - Simulator And iOS Device].

For more guides about THEOplayer please visit [THEO Docs] portal.

[//]: # (Sections reference)
[Create New Project]: #Create-New-Project
[Implementation]: #Implementation
[Build Project]: #Build-Project
[Summary]: #Summary

[//]: # (Links and Guides reference)
[THEO Knowledge Base - Xcode Setup]: ../knowledgebase-xcode-setup/README.md
[THEO Knowledge Base - Simulator And iOS Device]: ../knowledgebase-simulator-and-ios-device/README.md
[THEO Docs]: https://docs.portal.theoplayer.com/

[//]: # (Images references)
[01]: Images/createProject.png "Create Project"
[02]: Images/singleViewApp.png "Single View App"
[03]: Images/setProjectInfo.png "Set Project Info"
[04]: Images/setProjectUser.png "Set Project User"
[05]: Images/saveProject.png "Save Project"
[06]: Images/newProjectCreated.png "New Project Created"
[07]: Images/noAuthorWarning.png "No Author Warning"
[08]: Images/inputAuthorInfo.png "Input Author Info"
[09]: Images/openMainStoryboard.png "Open Main Storyboard"
[10]: Images/createLabel.png "Create Label"
[11]: Images/positionLabel.png "Position Label"
[12]: Images/createConstraintsForLabel.png "Create Constraints For Label"
[13]: Images/highlightLabel.png "Highlight Label"
[14]: Images/changeLabelToHelloWorld.png "Change Label To Hello World"
[15]: Images/buildProject.png "Build Project"
[16]: Images/projectBuildFailure.png "Project Build Failure"
[17]: Images/buildResultPopup.png "Build Result Popup"
