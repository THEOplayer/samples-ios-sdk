//
//  Stream.swift
//  theo_offline
//
//  Copyright © 2019 THEOPlayer. All rights reserved.
//

// MARK: - MetadataType enumeration declaration

enum MetadataType: Int {
    case id3
    case programDateTime
    case dateRange
}

// MARK: - Stream declaration

struct Stream {
    var name: String
    var title: String
    var url: String
    var mimeType: String
    var type:  MetadataType
}
