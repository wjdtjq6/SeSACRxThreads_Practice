//
//  SearchViewModel.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/6/24.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel {
    struct Input {
        let searchText: Observable<String>
    }
    struct Output {
        let data: Observable<[String]>
    }
    func transform(input: Input) -> Output {
        var data = Observable.just(["A", "B", "C", "AB", "D", "ABC", "BBB", "EC", "SA", "AAAB", "ED", "F", "G", "H"])
        return Output(data: data)
    }
}
