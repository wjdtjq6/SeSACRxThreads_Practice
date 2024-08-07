//
//  MovieViewModel2.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/7/24.
//

import Foundation
import RxSwift
import RxCocoa

class BoxOfficeViewModel2 {
    let disposeBag = DisposeBag()
    //tableView data
    private let movieList = Observable.just(["테스트1","테스트2","테스트3"])
    //collectionview data
    private var recentList = ["A","B"]//Observable.just([])
    struct Input {
        let searchButtonTap: ControlEvent<Void>
        let searchText: ControlProperty<String>
        //테이블뷰를 클릭할 때 들어오는 글자. 컬렉션 뷰에 업데이트
        let recentText: Observable<String>
    }
    struct Output {
        let movieList: Observable<[String]>//tableView
        let recentList: Observable<[String]>//collectionView
    }
    func transform(input: Input) -> Output {
        let recentList = BehaviorSubject(value: recentList)
        input.recentText
            .subscribe(with: self) { owner, value in
                print(value)
                owner.recentList.append(value)
                recentList.onNext(owner.recentList)
            }
            .disposed(by: disposeBag)
        input.searchButtonTap
            .subscribe(with: self) { owner, _ in
                print("tap")
            }
            .disposed(by: disposeBag)
        input.searchText
            .subscribe(with: self) { owner, _ in
                print("글자")
            }
            .disposed(by: disposeBag)
        return Output(movieList: movieList, recentList: recentList)
    }
}
