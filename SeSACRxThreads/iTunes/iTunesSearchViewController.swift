//
//  iTunesSearchViewController.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/9/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

class iTunesSearchViewController: UIViewController {
    let searchController = UISearchController(searchResultsController: nil)
    let tableView = UITableView()
    let viewModel = iTunesSearchViewModel()
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarcy()
        configureLayout()
        configureUI()
        bind()
    }
    func bind() {
        let transmissionList = PublishSubject<String>()
        let input = iTunesSearchViewModel.Input(searchButtonTap: searchController.searchBar.rx.searchButtonClicked, searchText: searchController.searchBar.rx.text.orEmpty, transmissionText: transmissionList)
        let output = viewModel.transform(input: input)
        
        output.iTunesList
            .bind(to: tableView.rx.items(cellIdentifier: iTunesTableViewCell.identifier, cellType: iTunesTableViewCell.self)) { (row, element, cell) in
                cell.firstLabel.text = element.trackCensoredName
                let url = URL(string: element.artworkUrl60)
                cell.iconImageView.kf.setImage(with: url)
                cell.downloadButton.setTitle(element.sellerName, for: .normal)
            }
            .disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Results.self))
            .map { "\($0.1.trackCensoredName)" }
            .subscribe(with: self) { owner, value in
                transmissionList.onNext(value)
                let vc = DetailViewController()
                vc.nameTitle = value
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    func configureHierarcy() {
        view.addSubview(searchController.searchBar)
        view.addSubview(tableView)
        navigationItem.searchController = searchController
        tableView.register(iTunesTableViewCell.self, forCellReuseIdentifier: iTunesTableViewCell.identifier)
        tableView.rowHeight = 100
    }
    func configureLayout() {
        searchController.searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(5)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "검색"
        navigationController?.navigationBar.prefersLargeTitles = true
        searchController.searchBar.placeholder = "게임, 앱, 스토리 등"
        searchController.searchBar.backgroundImage = UIImage()
    }
}
