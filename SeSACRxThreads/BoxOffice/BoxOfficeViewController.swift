//
//  BoxOfficeViewController.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/7/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class BoxOfficeViewController: UIViewController {
    let searchBar = UISearchBar()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout())
    let tableView = UITableView()
    let disposeBag = DisposeBag()
    let viewModel = BoxOfficeViewModel2()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureLayout()
        configureUI()
        bind2()
    }
    func bind2() {
        let recentText = PublishSubject<String>()
        let input = BoxOfficeViewModel2.Input(searchButtonTap: searchBar.rx.searchButtonClicked, searchText: searchBar.rx.text.orEmpty, recentText: recentText)
        let output = viewModel.transform(input: input)
        output.recentList
            .bind(to: collectionView.rx.items(cellIdentifier: MovieCollectionViewCell.identifier, cellType: MovieCollectionViewCell.self)) {(row, element, cell) in
                cell.label.text = "\(element),\(row)"
            }
            .disposed(by: disposeBag)
        output.movieList
            .bind(to: tableView.rx.items(cellIdentifier: MovieTableViewCell.identifier, cellType: MovieTableViewCell.self)) { (row,element,cell) in
                cell.appNameLabel.text = element.movieNm
                cell.downloadButton.setTitle(element.openDt, for: .normal)
            }
            .disposed(by: disposeBag)
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(String.self))
            .map { "검색어는 \($0.1)" }
            .subscribe(with: self) { owner, value in
                recentText.onNext(value)
            }
            .disposed(by: disposeBag)
    }
//    func bind() {
//        let recentText = PublishSubject<String>()
//        let input = BoxOfficeViewModel.Input(searchButtonTap: searchBar.rx.searchButtonClicked, searchText: searchBar.rx.text.orEmpty, recentText: recentText)
//        let output = viewModel.transform(input: input)
//        
//        output.recentList
//            .bind(to: collectionView.rx.items(cellIdentifier: MovieCollectionViewCell.identifier, cellType: MovieCollectionViewCell.self)) { (row, element, cell ) in
//                cell.label.text = "\(element),\(row)"
//            }
//            .disposed(by: disposeBag)
//        
//        output.movieList
//            .bind(to: tableView.rx.items(cellIdentifier: MovieTableViewCell.identifier, cellType: MovieTableViewCell.self)) { ( row, element, cell) in
//                cell.appNameLabel.text = element
//            }
//            .disposed(by: disposeBag)
//        
//        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(String.self))
//            .map { "검색어는 \($0.1)" }
//            .subscribe(with: self) { owner, value in
//                recentText.onNext(value)
//            }
//            .disposed(by: disposeBag)
//    }
    func configureHierarchy() {
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(tableView)
        navigationItem.titleView = searchBar
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
        tableView.rowHeight = 100
    }
    func configureLayout() {
        collectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            //make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    func configureUI() {
        view.backgroundColor = .white
        collectionView.backgroundColor = .link
        tableView.backgroundColor = .brown
    }
    static func layout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 40)
        layout.scrollDirection = .horizontal
        return layout
    }
}
