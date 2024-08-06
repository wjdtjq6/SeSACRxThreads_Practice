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
    var data = ["A", "B", "C", "AB", "D", "ABC", "BBB", "EC", "SA", "AAAB", "ED", "F", "G", "H"]
    let disposeBag = DisposeBag()
    struct Input {
        let searchText: ControlProperty<String?>
        let click: ControlEvent<Void>
    }
    struct Output {
        let list: BehaviorSubject<[String]>
        let click: ControlEvent<Void>
    }
    func transform(input: Input) -> Output {
        lazy var list = BehaviorSubject(value: data)
        // searchbar
        input.click//searchBar.rx.searchButtonClicked//input,output
            .withUnretained(self)
            .withLatestFrom(input.searchText.orEmpty) { void, text in
                return text /*+ "조합해서 추가 가능"*/
            }
            .bind(with: self) {owner, value in
                owner.data.insert(value, at: 0)
                list.onNext(owner.data)
                print("검색버튼 클릭")
            }
            .disposed(by: disposeBag)
        // value on chaged
        // 입력하자마자 통신 되는 것이 아니라 시간이 좀 지난 후 통신하고 싶을 때는?
        // -> debounce vs throttle
        
        //MARK: 실시간 검색기능
        input.searchText.orEmpty//searchBar.rx.text.orEmpty//input
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()// 값이 같다면 다시 호출하지 마
            .bind(with: self) { owner, value in
                print("실시간 검색", value)
                let result = value.isEmpty ? owner.data : owner.data.filter { $0.contains(value)} //원본 데이터를 건들지 않고 새로운 배열을 만듬
                list.onNext(result) // onnext 값 교체
                print(list)
            }
            .disposed(by: disposeBag)
        return Output(list: list, click: input.click)
    }
}
