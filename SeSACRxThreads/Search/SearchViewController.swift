//
//  SearchViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 8/1/24.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
   
    private let tableView: UITableView = {
       let view = UITableView()
        view.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
        view.backgroundColor = .white
        view.rowHeight = 180
        view.separatorStyle = .none
       return view
     }()
    
    let searchBar = UISearchBar()
       
    let disposeBag = DisposeBag()
    let viewModel = SearchViewModel2()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configure()
        setSearchController()
        //bind()
        bindRefactoring()
    }
    func bindRefactoring() {
        viewModel.list
            .bind(to: tableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) { (row, element, cell ) in
                cell.appNameLabel.text = element
                cell.appIconImageView.backgroundColor = .systemCyan
                cell.downloadButton.rx.tap
                    .subscribe(with: self) { owner, _ in
                        print("button Clicked")
                        owner.navigationController?.pushViewController(DetailViewController(), animated: true)
                    }
                    .disposed(by: cell.disposeBag)//vc와 생명주기가 같지 않기 때문에 셀의 disposeBag을 사용해야함
            }
        searchBar.rx.text.orEmpty
            .bind(to: viewModel.text)
            .disposed(by: disposeBag)
        searchBar.rx.searchButtonClicked
            .bind(to: viewModel.click)
            .disposed(by: disposeBag)
    }
//    func bind() {
//        let input = SearchViewModel.Input(searchText: searchBar.rx.text, click: searchBar.rx.searchButtonClicked)
//        let output = viewModel.transform(input: input)
//        
//        output.list
//            .bind(to: tableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) { (row, element, cell) in
//                
//                cell.appNameLabel.text = element
//                cell.appIconImageView.backgroundColor = .systemBlue
//                cell.downloadButton.rx.tap
//                    .subscribe(with: self) { owner, _ in
//                        print("버튼 클릭")
//                        owner.navigationController?.pushViewController(DetailViewController(), animated: true)
//                    }
//                    .disposed(by: cell.disposeBag) // 뷰 컨트롤러와 생명주기가 같지 않기 때문에 셀의 disposeBag을 사용해야함
//            }
//            .disposed(by: disposeBag)
//    }
    private func setSearchController() {
        view.addSubview(searchBar)
        navigationItem.titleView = searchBar
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "추가", style: .plain, target: self, action: #selector(plusButtonClicked))
    }
    
    @objc func plusButtonClicked() {
        print("추가 버튼 클릭")
    }

    
    private func configure() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

    }
}
