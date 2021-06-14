//
//  RemoteConfig.swift
//  Programmable_Stream
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

import THEOplayerSDK

class AdsConfig: Decodable {
    var showCountdown: Bool?
    var preload: String?
    var vpaidMode: String? // Unsupported in iOS SDK
    var adsConfiguration: AdsConfiguration? {
        get {
            if let showCountdown = showCountdown,
                let preload = preload {
                return AdsConfiguration(showCountdown: showCountdown, preload: AdPreloadType(rawValue: preload)!)
            } else {
                return nil
            }
        }
    }

    private enum CodingKeys : String, CodingKey {
        case showCountdown
        case preload
        case vpaidMode
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        showCountdown = try container.decodeIfPresent(Bool.self, forKey: .showCountdown)
        preload = try container.decodeIfPresent(String.self, forKey: .preload)
        vpaidMode = try container.decodeIfPresent(String.self, forKey: .vpaidMode)

        if let preload = preload {
            guard AdPreloadType(rawValue: preload) != nil else {
                throw DecodingError.typeMismatch(AdsConfig.self, DecodingError.Context(codingPath: [ CodingKeys.preload ], debugDescription: "\(preload) is not valid AdPreloadType"))
            }
        }
    }
}

class ChromecastConfiguration: Decodable {
    let appID: String?
}

class CastConfig: Decodable {
    let chromecast: ChromecastConfiguration?
    let strategy: String?
    var castConfiguration: CastConfiguration? {
        get {
            if let strategy = strategy {
                return CastConfiguration(strategy: CastStrategy(rawValue: strategy))
            } else {
                return nil
            }
        }
    }

    private enum CodingKeys : String, CodingKey {
        case chromecast
        case strategy
    }
}

class VerizonMediaUiConfig: Decodable {
    var adBreakMarkers: Bool?
    var adNotification: Bool?
    var assetMarkers: Bool?
    var contentNotification: Bool?
    var verizonMediaUiConfiguration: VerizonMediaUiConfiguration? {
        if let adBreakMarkers = adBreakMarkers,
            let adNotification = adNotification,
            let assetMarkers = assetMarkers,
            let contentNotification = contentNotification {
            return VerizonMediaUiConfiguration(contentNotification: adBreakMarkers, adNotification: adNotification, assetMarkers: assetMarkers, adBreakMarkers: contentNotification)
        } else {
            return nil
        }
    }

    private enum CodingKeys : String, CodingKey {
        case adBreakMarkers
        case adNotification
        case assetMarkers
        case contentNotification
    }
}

class VerizonMediaConfig: Decodable {
    var defaultSkipOffset: Int?
    var onSeekOverAd: String?
    var ui: VerizonMediaUiConfig?
    var verizonMediaConfiguration: VerizonMediaConfiguration? {
        get {
            let skippedAdStrategy = (onSeekOverAd != nil) ? SkippedAdStrategy(rawValue: onSeekOverAd!) : nil
            return VerizonMediaConfiguration(defaultSkipOffset: defaultSkipOffset, onSeekOverAd: skippedAdStrategy, ui: ui?.verizonMediaUiConfiguration)
        }
    }

    private enum CodingKeys : String, CodingKey {
        case defaultSkipOffset
        case onSeekOverAd
        case ui
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        defaultSkipOffset = try container.decodeIfPresent(Int.self, forKey: .defaultSkipOffset)
        onSeekOverAd = try container.decodeIfPresent(String.self, forKey: .onSeekOverAd)

        if let onSeekOverAd = onSeekOverAd {
            guard SkippedAdStrategy(rawValue: onSeekOverAd) != nil else {
                throw DecodingError.typeMismatch(VerizonMediaConfig.self, DecodingError.Context(codingPath: [ CodingKeys.onSeekOverAd ], debugDescription: "\(onSeekOverAd) is not valid SkippedAdStrategy"))
            }
        }
    }
}

class UIConfig: Decodable {
    var language: String? // The only field supported by iOS SDK
    var uiConfiguration: UIConfiguration? {
        get {
            if let language = language {
                return UIConfiguration(language: language)
            } else {
                return nil
            }
        }
    }

    private enum CodingKeys : String, CodingKey {
        case language
    }
}

class PlayerConfiguration: Decodable {
    var ads: AdsConfig?
    var allowMixedContent: Bool?
    var allowNativeFullscreen: Bool?
    var analytics: NSObject? // Ignore as per requirement
    var cast: CastConfig?
    var hlsDateRange: Bool?
    var initialRendition: String?
    var isEmbeddable: Bool?
    var libraryLocation: String?
    var liveOffset: Double?
    var mutedAutoplay: String? // Unsupported by iOS SDK
    var persistVolume: Bool?
    var ui: UIConfig?
    var verizonMedia: VerizonMediaConfig?

    private enum CodingKeys : String, CodingKey {
        case ads
        case allowMixedContent
        case allowNativeFullscreen
        case cast
        case hlsDateRange
        case initialRendition
        case isEmbeddable
        case libraryLocation
        case liveOffset
        case mutedAutoplay
        case persistVolume
        case ui
        case verizonMedia
    }

    func getTheoPlayerConfiguration(chromeless: Bool = false, googleIMA: Bool = false, pictureInPicture: Bool = false) -> THEOplayerConfiguration? {
        return THEOplayerConfiguration(chromeless: chromeless, googleIMA: googleIMA, pictureInPicture: pictureInPicture, ads: ads?.adsConfiguration, ui: ui?.uiConfiguration, cast: cast?.castConfiguration, hlsDateRange: hlsDateRange, verizonMedia: verizonMedia?.verizonMediaConfiguration, license: "your_license_string")
    }
}

/* Remote decodable configuration as per doc:
    PlayerConfiguration doc:
        https://docs.portal.theoplayer.com/docs/api-reference/theoplayer-playerconfiguration
    SourceDescription doc:
        https://docs.portal.theoplayer.com/docs/api-reference/theoplayer-sourcedescription
 */
class RemoteConfig: Decodable {
    var playerConfiguration: PlayerConfiguration?
    var source: SourceDescription?
}
