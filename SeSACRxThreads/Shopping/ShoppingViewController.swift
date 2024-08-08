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
class ShoppingViewController: UIViewController {
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
    let searchBar = UISearchBar()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    let disposeBag = DisposeBag()
    let viewModel = ShoppingViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureUI()
        bind()
    }
    func bind() {
        let recentText = PublishSubject<String>()
        let input = ShoppingViewModel.Input(enterTextField: shoppingTextField.rx.controlEvent(.editingDidEndOnExit), text: shoppingTextField.rx.text.orEmpty, select: tableView.rx.itemSelected, recentText: recentText)
        let output = viewModel.transform(input: input)
        //컬렉션 뷰
        output.recentList
            .bind(to: collectionView.rx.items(cellIdentifier: ShoppingCollectionViewCell.identifier, cellType: ShoppingCollectionViewCell.self)) { (row,element,cell) in
                cell.label.text = "\(element)"
            }
            .disposed(by: disposeBag)
        //즐겨찾기 및 완료 기능
        output.list
            .bind(to: tableView.rx.items(cellIdentifier: "ShoppingTableViewCell", cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
                var newElement = element

                cell.title.text = element.title
                cell.leftButton.setImage(UIImage(systemName: element.isDone ? "checkmark.square.fill" : "checkmark.square"), for: .normal)
                cell.rightButton.setImage(UIImage(systemName: element.isLike ? "star.fill" : "star"), for: .normal)

                cell.leftButton.rx.tap
                    .subscribe(onNext: { _ in
                        newElement.isDone.toggle()
                        cell.leftButton.setImage(UIImage(systemName: newElement.isDone ? "checkmark.square.fill" : "checkmark.square"), for: .normal)
                    })
                    .disposed(by: cell.disposeBag)
                cell.rightButton.rx.tap
                    .subscribe(onNext: { _ in
                        newElement.isLike.toggle()
                        cell.rightButton.setImage(UIImage(systemName: newElement.isLike ? "star.fill" : "star"), for: .normal)
                    })
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        //화면 전환 기능
        output.select//tableView.rx.itemSelected//Viewmodel,input,output
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(DetailViewController(), animated: true)
            }
            .disposed(by: disposeBag)
        //컬렉션뷰 셀을 선택했을때 테이블뷰에 할 일이 추가되도록
        Observable.zip(collectionView.rx.itemSelected, collectionView.rx.modelSelected(String.self))
            .map { "\($0.1)" }
            .subscribe(with: self) { owner, value in
                recentText.onNext(value)
            }
            .disposed(by: disposeBag)
    }
    func configureHierarchy() {
        view.addSubview(uiView)
        view.addSubview(shoppingTextField)
        view.addSubview(addButton)
        view.addSubview(tableView)
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        collectionView.register(ShoppingCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingCollectionViewCell.identifier)
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
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(uiView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            //make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "쇼핑"
    }
    static func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 40)
        layout.scrollDirection = .horizontal
        return layout
    }
}
