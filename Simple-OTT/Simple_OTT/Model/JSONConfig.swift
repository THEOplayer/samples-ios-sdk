//
//  JSONConfig.swift
//  Simple_OTT
//
//  Copyright © 2020 THEOPlayer. All rights reserved.
//

class Content: Decodable {
    var name: String
    var description: String
    var imageUrl: String
    var videoSource: String
}

class Live: Decodable {
    var channels: [Content]
}

class OnDemend: Decodable {
    var vods: [Content]
}

class Offline: Decodable {
    var vods: [Content]
}

class Config: Decodable {
    var live: Live
    var onDemand: OnDemend
    var offline: Offline
}

// MARK: - JSON format used in Config.json

class JSONConfig: Decodable {
    var config: Config
}
