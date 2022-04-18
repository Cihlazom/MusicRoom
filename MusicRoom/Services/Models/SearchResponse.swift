//
//  SearchResponse.swift
//  MusicRoom
//
//  Created by Vladislav on 16.04.2022.
//

import Foundation

struct SearchResponse: Codable {
    var resultCount: Int
    var results: [Track]
}

struct Track: Codable {
    var artistName: String
    var collectionName: String?
    var trackName: String
    var artworkUrl100: String?
    var previewUrl: String?
}
