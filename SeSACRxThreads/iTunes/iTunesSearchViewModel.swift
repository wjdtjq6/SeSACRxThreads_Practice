//
//  iTunesSearchViewModel.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/9/24.
//

import Foundation
import RxSwift
import RxCocoa

class iTunesSearchViewModel: BaseViewModel {
    let disposeBag = DisposeBag()
    
    private var list = iTunes.init(resultCount: 0, results: [])
    private lazy var iTunesList = Observable.just(list.results)
    private var transmissionList = [""]
    struct Input {
        let searchButtonTap: ControlEvent<Void>
        let searchText: ControlProperty<String>
        let transmissionText: Observable<String>//테이블뷰를 클릭할 때 들어오는 글자, 다음뷰에 업데이트
    }
    struct Output{
        let iTunesList: Observable<[Results]>
        let transmissionList: Observable<[String]>
    }
    func transform(input: Input) -> Output {
        let iTunesList = PublishSubject<[Results]>()
        let transmissionList = BehaviorSubject(value: transmissionList)
        let noResult = [Results(trackCensoredName: "소지섭", sellerName: "받기", artworkUrl60: "https://is1-ssl.mzstatic.com/image/thumb/Purple126/v4/75/e7/3e/75e73e6c-859a-d090-2896-4659e16b72cf/AppIcon-0-0-1x_U007emarketing-0-0-0-10-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/60x60bb.jpg")]

        input.searchButtonTap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withLatestFrom(input.searchText)
            .debug("체크1")
            .distinctUntilChanged()
            .flatMap({ value in
//                iTunesNetworkManager.shared.calliTunes(term: value).catch { error in
//                    print(error.localizedDescription)
//                    return Observable.empty()
//                }
                iTunesNetworkManager.shared.fetchITunesSingle(term: value).catch { error in
                    print(error.localizedDescription)
                    return Single.just(iTunes(resultCount: 1, results: noResult))
                }
            })
            .debug("체크2")
            .subscribe(with: self, onNext: { owner, iTunes in
                dump(iTunes.results)
                print("아이튠즈.결과")
                iTunesList.onNext(iTunes.results)
            }, onError: { owner, error in
                print(error)
            }, onCompleted: { owner in
                print("completed")
            }, onDisposed: { owner in
                print("disposed")
            })
            .disposed(by: disposeBag)
        
        input.searchText
            .subscribe(with: self) { owner, string in
                print(string,"글자")
            }
            .disposed(by: disposeBag)
        
        return Output(iTunesList: iTunesList, transmissionList: transmissionList)
    }
}

