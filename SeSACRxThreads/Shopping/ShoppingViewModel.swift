//
//  ShoppingViewModel.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/6/24.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

struct Data {
    let title: String
    var isDone = false
    var isLike = false
}
class ShoppingViewModel {
    
    let disposeBag = DisposeBag()
    //테이블뷰 데이터
    private var data = [
        Data(title: "그립톡 구매하기",isDone: true, isLike: false),
        Data(title: "사이다 구매", isDone: false, isLike: true)
    ]
    private lazy var list = BehaviorSubject(value: data)//원래 BehaviorSubject
    //컬렉션뷰 데이터
    private var recentList = ["키보드","거치대","마우스","트랙패드"]

    struct Input {
        let enterTextField: ControlEvent<()>//shoppingTextField.rx.controlEvent
        var text: ControlProperty<String>//shoppingTextField.rx.text.orempty
        let select: ControlEvent<IndexPath>//tableView.rx.itemSelected
        //테이블뷰 클릭 시 들어오는 글자. 컬렉션뷰에 업데이트/테이블뷰에 업데이트해야함
        let recentText: Observable<String>
        let cellLeftTap: Observable<Int>//추가하면 완료,즐겨찾기 초기화되는 문제 해결
        let rightTap: Observable<Int>//추가하면 완료,즐겨찾기 초기화되는 문제 해결
    }
    struct Output {
        let list: BehaviorSubject<[Data]>
        let recentList: Observable<[String]>
        let enterTextField: ControlEvent<()>//shoppingTextField.rx.controlEvent
        let select: ControlEvent<IndexPath>
    }
    func transform(input: Input) -> Output {
        let recentList = BehaviorSubject(value: recentList)
        let list = BehaviorSubject(value: data)
        //추가하면 완료,즐겨찾기 초기화되는 문제 해결
        input.cellLeftTap
            .bind { row in
                var listValue = try! list.value()
                listValue[row].isDone.toggle()
                self.data[row].isDone.toggle()
                list.onNext(listValue)
            }
            .disposed(by: disposeBag)
        input.rightTap
            .bind { row in
                var listValue = try! list.value()
                listValue[row].isLike.toggle()
                self.data[row].isLike.toggle()
                list.onNext(listValue)
            }
            .disposed(by: disposeBag)
        //
        //tableView에 추가
        input.recentText
            .subscribe(with: self) { owner, value in
                print(value,"테이블뷰")
                owner.data.append(Data(title: value,isDone: false, isLike: false))//recentList이면 컬렉션뷰에 추가됨
                list.onNext(owner.data)//recentList이면 컬렉션뷰에 추가됨
            }
            .disposed(by: disposeBag)

        input.enterTextField
            .withLatestFrom(input.text)
            .subscribe(with: self) { owner, value in
                print(value,"엔터")
                owner.data.insert(Data(title: value), at: owner.data.endIndex)
                list.onNext(owner.data)
                //input.text = ""
            }
            .disposed(by: disposeBag)

        input.select
            .subscribe(with: self) { owner, _ in
            }
            .disposed(by: disposeBag)
        
        //실시간 검색 기능
        input.text
            .distinctUntilChanged()
            .debug("검색")
            .subscribe(with: self) { owner, value in
                print(value,"text")
                let result = value.isEmpty ? owner.data : owner.data.filter({ $0.title.contains(value) })
                list.onNext(result)
            }
            .disposed(by: disposeBag)
        return Output(list: list, recentList: recentList, enterTextField: input.enterTextField, select: input.select)
    }
}

