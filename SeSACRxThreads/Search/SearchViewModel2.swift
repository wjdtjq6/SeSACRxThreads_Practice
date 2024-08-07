//
//  SearchViewModel2.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/7/24.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel2 {
    //input
    let text = PublishSubject<String>()
    let click = PublishSubject<Void>()
    //dummy
    var data = ["A", "B", "C", "AB", "D", "ABC", "BBB", "EC", "SA", "AAAB", "ED", "F", "G", "H"]
    let disposeBag = DisposeBag()
    //output
    lazy var list = BehaviorSubject(value:data)
    //list
    init() {
//        text
//            .subscribe { text in
//                print(text)
//            }
//            .disposed(by: disposeBag)
        text
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()//값이 같다면 다시 호출하지 마
            .subscribe(with: self) { owner, value in
                print("realTime search",value)
                let result = value.isEmpty ? owner.data : owner.data.filter({ $0.contains(value) })//원본 데이터를 건들지 않고 새로운 배열을 만듬
                owner.list.onNext(result)//onnext값 교체
                print(self.list)
            }
            .disposed(by: disposeBag)
        click
            .subscribe(with: self) { owner, value in
                print(value)
            }
            .disposed(by: disposeBag)
        click
            .withUnretained(self)
            .withLatestFrom(text)
            .subscribe(with: self) { owner, value in
                print(value)
                owner.data.insert(value, at: 0)
                owner.list.onNext(owner.data)
                print("button clicked")
            }
            .disposed(by: disposeBag)
    }
}
