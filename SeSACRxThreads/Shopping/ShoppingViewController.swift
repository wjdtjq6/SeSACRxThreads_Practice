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

struct Data {
    let title: String
    var isDone = false
    var isList = false
}
class ShoppingViewController: UIViewController {
    var data = [
        Data(title: "그립톡 구매하기",isDone: true, isList: true),
        Data(title: "사이다 구매", isDone: false, isList: true)
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
        $0.register(SearchTableViewCell.self, forCellReuseIdentifier: "SearcgTableViewCell")
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
        list
            .bind(to: tableView.rx.items(cellIdentifier: "ShoppingTableViewCell", cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
                
                cell.title.text = element.title
                cell.leftButton.rx.tap
                    .subscribe { _ in
                        cell.leftButton.isSelected.toggle()
                    }
                    .disposed(by: self.disposeBag)
                cell.rightButton.rx.tap
                    .subscribe { _ in
                        cell.rightButton.isSelected.toggle()
                    }
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
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
