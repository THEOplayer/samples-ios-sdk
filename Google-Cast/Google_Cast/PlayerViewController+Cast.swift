//
//  PlayerViewController+Cast.swift
//  Google_Cast
//
//  Copyright © 2024 THEOPlayer. All rights reserved.
//

import THEOplayerSDK
import THEOplayerGoogleCastIntegration
import THEOplayerTHEOliveIntegration
import GoogleCast

class PlayerViewControllerCast: PlayerViewController {
    // Chromecast button on the navigation bar
    private var chromeCastButton: GCKUICastButton!
    private var changeSourceButton: UIButton!
    private var joinLeaveToggle: UISwitch!
    private var playbackRateToggle: UISwitch!

    private var bigBuckSource = TypedSource(src: "https://cdn.theoplayer.com/video/big_buck_bunny/big_buck_bunny.m3u8", type: "application/x-mpegurl")
    private var sources: Array<SourceDescription> = []
    private var whichSource: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sources = [SourceDescription(source: bigBuckSource), source]
        self.changeSourceButton = UIButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(12), height: CGFloat(12)))
        self.joinLeaveToggle = UISwitch(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(12), height: CGFloat(12)))
        self.playbackRateToggle = UISwitch(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(12), height: CGFloat(12)))

        self.changeSourceButton.setTitle("source", for: .normal)
        self.changeSourceButton.addTarget(self, action:#selector(changeSource), for: .touchUpInside)
        self.joinLeaveToggle.addTarget(self, action: #selector(toggleJoinLeave(_:)), for: .valueChanged)
        self.playbackRateToggle.addTarget(self, action: #selector(togglePlaybackRate(_:)), for: .valueChanged)

        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: self.playbackRateToggle)]
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: self.changeSourceButton!), UIBarButtonItem(customView: self.joinLeaveToggle)]
        
        self.prepareCustomChromecastLogic()
        // Configure the player's source to initialise playback
        // the second source is the fallback HLS source
        self.theoplayer.source = SourceDescription(sources: [
            TheoLiveSource(channelId: "4ium9mw6i2p07ndm9eez1wqwa"),
            TypedSource(src: "https://demo.unified-streaming.com/k8s/live/scte35.isml/.m3u8", type: "application/x-mpegURL")])
        // self.theoplayer.source = source
    }

    override func setupIntegrations() {
//        let castConfiguration: CastConfiguration = CastConfiguration(strategy: .manual)
//        let castIntegration: THEOplayerSDK.Integration = GoogleCastIntegrationFactory.createIntegration(on: self.theoplayer, with: castConfiguration)
//        self.theoplayer.addIntegration(castIntegration)
    }
    
    @IBAction func changeSource() {
        whichSource = (whichSource + 1) % 2
        theoplayer.source = sources[whichSource]
    }
    
    @IBAction func togglePlaybackRate(_ toggle: UISwitch!) {
        if toggle.isOn {
            theoplayer.playbackRate = 2.0
        } else {
            theoplayer.playbackRate = 1.0
        }
    }

    
    @IBAction func toggleJoinLeave(_ toggle: UISwitch!) {
        if (toggle.isOn) {
            theoplayer?.cast?.chromecast?.join()
        } else {
            theoplayer?.cast?.chromecast?.leave()
        }
    }

    private func prepareCustomChromecastLogic() {
//        // Set up Chromecast button
//        self.chromeCastButton = GCKUICastButton(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(24), height: CGFloat(24)))
//        
//        self.chromeCastButton.tintColor = UIColor.white
//        self.navigationItem.rightBarButtonItems?.append(UIBarButtonItem(customView: self.chromeCastButton!))
//        self.chromeCastButton.delegate = self
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
