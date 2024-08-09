//
//  Movie.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/9/24.
//

import Foundation

struct Movie: Decodable {
    let boxOfficeResult: BoxOfficeResult
}
struct BoxOfficeResult: Decodable {
    let dailyBoxOfficeList: [DailyBoxOfficeList]
}
struct DailyBoxOfficeList: Decodable {
    let movieNm: String
    let openDt: String
}
