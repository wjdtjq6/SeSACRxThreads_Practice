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
        let movieList: Observable<[DailyBoxOfficeList]>//Observable<[String]>//tableView
        let recentList: Observable<[String]>//collectionView
    }
    func transform(input: Input) -> Output {
        let recentList = BehaviorSubject(value: recentList)
        let boxOfficeList = PublishSubject<[DailyBoxOfficeList]>()
        input.recentText
            .subscribe(with: self) { owner, value in
                print(value)
                owner.recentList.append(value)
                recentList.onNext(owner.recentList)
            }
            .disposed(by: disposeBag)
        //검색버튼클릭 시 서버 통신 진행
        //Observable안에 Observable이 또 이따
        //>> Observable<Observable<value>>
        input.searchButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.searchText)//20240808
            .debug("체크1")
            .distinctUntilChanged()
            .map({ guard let intText = Int($0) else { return 20240808 }
                return intText
            })
            .debug("체크2")
            .map({ return"\($0)" })//String으로 바꿔줌 => "20240808"
            .flatMap({ value in//위는 String 얘는 Observable<Observable<value>>임. 난 Observable<value>를 원함 => map -> flatMap => .subscribe 하면 한 번에 value가 나옴
                NetworkManager.shared.callBoxOffice(date: value).catch { error in
                    print(error.localizedDescription)
                    return Observable.empty()
                } })
            .debug("체크3")
            .subscribe(with: self, onNext: { owner, movie in
                dump(movie .boxOfficeResult.dailyBoxOfficeList)
                boxOfficeList.onNext(movie.boxOfficeResult.dailyBoxOfficeList)
            }, onError: { owner, error in
                print(error)
            }, onCompleted: { owner in
                print("completed")
            }, onDisposed: { owner in
                print("disposed")
            })
            .disposed(by: disposeBag)
        //
        input.searchText
            .subscribe(with: self) { owner, _ in
                print("글자")
            }
            .disposed(by: disposeBag)
        return Output(movieList: boxOfficeList, recentList: recentList)
    }
}
