//
//  SignInViewModel2.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/12/24.
//

import Foundation
import RxSwift
import RxCocoa
//프로토콜은 형태만 갖추면 되고, 구현은 다른 곳에서 이루어짐
//Input, Output이 제네릭이었으면 좋겠다
//Swift Generic -> associated type
protocol BaseViewModel {//<Input> {
    //그냥 제네릭임!
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
    var disposeBag: DisposeBag { get }//안써도 강제화해야 해서 뺄지 말지 고민!
}/*
class TestViewModel: BaseViewModel {
    /*
    var jimmy: Input = "jimmy"
    var jack: Input = "jack"
    var ios: Input = "ios"
    var hi: Output = false
    typealias Input = String
    typealias Output = Bool
    
    func transform(input: String) -> Bool {
        <#code#>
    }
    */
    
    typealias Input = jimmy
    typealias Output = pepper
    struct jimmy {
        
    }
    struct pepper {
        
    }
    func transform(input: jimmy) -> pepper {
        return
    }
    var disposeBag = DisposeBag()
}*/
class SignInViewModel2: BaseViewModel {
    var disposeBag = DisposeBag()
    
    struct Input {
        let tap: ControlEvent<Void>
    }
    struct Output {
        let text: Driver<Joke>
    }
    //tap했을 때 서버 통신 -> 메인 쓰레드에서 동작하지 않을 수 있고...
    //=>Observable => PublishSubject => PublishRelay
    func transform(input: Input) -> Output {
        let result = input.tap
            .flatMap {
                NetworkManager.shared.fetchJokeWithSingle().catch { error in
                    print(error.localizedDescription)
                    return Single<Joke>.never()
                }
            }
            //.asSingle()//MARK: 1.뷰에 결과가 안나와, buttonTap에 이벤트 전달이 안돼
        //두번째 버튼은 실패로 나오고,세번째부터는 클릭도 안됨
        //=> 전체 스트림을 모두 single로 만들어 버림. 있다고 쓰지말자.
            .asDriver(onErrorJustReturn: Joke(joke: "실패", id: 0))
        return Output(text: result)
    }
}
//MARK: 탭 옵저버블 내에 네트워크 옵저버블이 있는데, 탭 옵저버블은 살아잇꼬 네트워크가 오유를 보내면
//3.자식 스트림이 에러를 방출하더라도 부모스트림이 에러를 안받고 dispose가 안되고 stream이 유지되게!
//핵심>>에러 처리 + 스트림유지
