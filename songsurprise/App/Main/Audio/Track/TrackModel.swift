//
//  TrackModel.swift
//  songsurprise
//
//  Created by resoul on 12.09.2024.
//

struct TrackModel: Decodable {
    let id: Int
    let trackName: String
    let imageName: String
    let artistName: String
    let endpoint: String
}
