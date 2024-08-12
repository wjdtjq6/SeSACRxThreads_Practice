//
//  iTunes.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/9/24.
//

import Foundation

struct iTunes: Decodable {
    let resultCount: Int
    let results: [Results]
}
struct Results: Decodable {
    let trackCensoredName: String
    let sellerName: String
    let artworkUrl60: String
}
