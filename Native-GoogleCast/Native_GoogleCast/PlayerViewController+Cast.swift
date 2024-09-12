//
//  PlayerViewController+Cast.swift
//  Native_GoogleCast
//
//  Copyright © 2024 THEOPlayer. All rights reserved.
//

import THEOplayerSDK
import THEOplayerGoogleCastIntegration
import GoogleCast

class PlayerViewControllerCast: PlayerViewController {
    // Chromecast button on the navigation bar
    private var chromeCastButton: GCKUICastButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.prepareCustomChromecastLogic()

        // Configure the player's source to initialise playback
        self.theoplayer.source = source
    }

    override func setupIntegrations() {
        let castConfiguration: CastConfiguration = CastConfiguration(strategy: .manual)
        let castIntegration: THEOplayerSDK.Integration = GoogleCastIntegrationFactory.createIntegration(on: self.theoplayer, with: castConfiguration)
        self.theoplayer.addIntegration(castIntegration)
    }

    private func prepareCustomChromecastLogic() {
        // Set up Chromecast button
        self.chromeCastButton = GCKUICastButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(24), height: CGFloat(24)))

        self.chromeCastButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.chromeCastButton!)

        self.chromeCastButton.delegate = self
    }
}

extension PlayerViewControllerCast: GCKUICastButtonDelegate {
    // Workaround due to existing bug. Fix is due in the upcoming THEOplayer releases.
    // Avoid using the `castState: GCKCastState` parameter, instead use `theoplayer.cast.chromecast.state`.
    // Internally both of the above are in sync.
    func castButtonDidTap(_ castButton: GCKUICastButton, toPresentDialogFor castState: GCKCastState) {
        guard let chromecast = self.theoplayer.cast?.chromecast else {
            return
        }
        if chromecast.state == PlayerCastState.available {
            chromecast.start()
        } else if chromecast.state == PlayerCastState.connected || chromecast.state == PlayerCastState.connecting {
            chromecast.stop()
        }
    }
}
