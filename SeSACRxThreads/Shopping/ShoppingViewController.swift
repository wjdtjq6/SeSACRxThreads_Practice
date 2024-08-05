//
//  ShoppingViewController.swift
//  SeSACRxThreads
//
//  Created by t2023-m0032 on 8/3/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Then
/*
 1.즐겨찾기 및 완료 기능 ㅇㅇㅇㅇㅇ
 2.다음 페이지로 화면 전환 가능 ㅇㅇㅇㅇㅇ
 3.구독 중첩 확인 ㅇㅇㅇㅇ
 4.실시간 검색 기능 ㅇㅇㅇ
 5.로드
 6.추가 ㅇㅇㅇㅇ
 7.수정
 8.삭제
 */
struct Data {
    let title: String
    var isDone = false
    var isLike = false
}
class ShoppingViewController: UIViewController {
    var data = [
        Data(title: "그립톡 구매하기",isDone: true, isLike: true),
        Data(title: "사이다 구매", isDone: false, isLike: true)
    ]
    lazy var list = BehaviorSubject(value: data)
    let uiView = UIView().then {
        $0.backgroundColor = .systemGray6
        $0.layer.cornerRadius = 10
    }
    let shoppingTextField = UITextField().then {
        $0.placeholder = "무엇을 구매하실 건가요?"
    }
    let addButton = UIButton().then {
        $0.setTitle("추가", for: .normal)
        $0.backgroundColor = .systemGray5
        $0.layer.cornerRadius = 10
        $0.setTitleColor(.black, for: .normal)
    }
    let tableView = UITableView().then {
        $0.register(ShoppingTableViewCell.self, forCellReuseIdentifier: "ShoppingTableViewCell")
        $0.rowHeight = 50
        $0.separatorStyle = .none
    }
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureUI()
        bind()
    }
    func bind() {
        //추가 기능
        shoppingTextField.rx.controlEvent(.editingDidEndOnExit)
            .withUnretained(self)
            .withLatestFrom(shoppingTextField.rx.text.orEmpty) { void, text in
                    return text
            }
            .bind(with: self) { owner, value in
                owner.data.insert(Data(title: value), at: 0)
                owner.list.onNext(owner.data)
                owner.shoppingTextField.text = ""
            }
            .disposed(by: disposeBag)
        //실시간 검색 기능
        shoppingTextField.rx.text.orEmpty
            .debounce(RxTimeInterval.milliseconds(1000), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(with: self) { owner, value in
                let result = value == "" ? owner.data : owner.data.filter({ $0.title.contains(value) })
                owner.list.onNext(result)
            }
            .disposed(by: disposeBag)
        //즐겨찾기 및 완료 기능
        list
            .bind(to: tableView.rx.items(cellIdentifier: "ShoppingTableViewCell", cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
                var newElement = element

                cell.title.text = element.title
                cell.leftButton.setImage(UIImage(systemName: element.isDone ? "checkmark.square.fill" : "checkmark.square"), for: .normal)
                cell.rightButton.setImage(UIImage(systemName: element.isLike ? "star.fill" : "star"), for: .normal)

                cell.leftButton.rx.tap
                    .subscribe(onNext: { _ in
                        newElement.isDone.toggle()
                        cell.leftButton.setImage(UIImage(systemName: element.isDone ? "checkmark.square.fill" : "checkmark.square"), for: .normal)
                    })
                    .disposed(by: self.disposeBag)
                cell.rightButton.rx.tap
                    .subscribe(onNext: { _ in
                        newElement.isLike.toggle()
                        newElement.isLike ? cell.rightButton.setImage(UIImage(systemName: "star.fill"), for: .normal) : cell.rightButton.setImage(UIImage(systemName: "star"), for: .normal)
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        //화면 전환 기능
        tableView.rx.itemSelected
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(DetailViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
    func configureHierarchy() {
        view.addSubview(uiView)
        view.addSubview(shoppingTextField)
        view.addSubview(addButton)
        view.addSubview(tableView)
    }
    func configureLayout() {
        uiView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.height.equalTo(70)
        }
        shoppingTextField.snp.makeConstraints { make in
            make.centerY.equalTo(uiView)
            make.leading.equalTo(uiView).offset(10)
            make.height.equalTo(50)
            make.width.equalTo(300)
        }
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(uiView)
            make.trailing.equalTo(uiView).inset(10)
            make.width.equalTo(50)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(uiView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "쇼핑"
    }
}
