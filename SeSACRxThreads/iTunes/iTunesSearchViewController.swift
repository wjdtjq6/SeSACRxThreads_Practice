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
    let searchBar = UISearchBar()
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
        let input = iTunesSearchViewModel.Input(searchButtonTap: searchBar.rx.searchButtonClicked, searchText: searchBar.rx.text.orEmpty, transmissionText: transmissionList)
        let output = viewModel.transform(input: input)
        
        output.iTunesList
            .bind(to: tableView.rx.items(cellIdentifier: iTunesTableViewCell.identifier, cellType: iTunesTableViewCell.self)) { (row, element, cell) in
                cell.firstLabel.text = element.collectionName
                //let url = URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/a0/46/c2/a046c209-7cc8-024c-d82b-3f198f043c97/8809492035840.jpg/30x30bb.jpg")
                let url = URL(string: element.artworkUrl30)
                cell.iconImageView.kf.setImage(with: url)
                cell.downloadButton.setTitle(element.artistName, for: .normal)
            }
            .disposed(by: disposeBag)
        
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Results.self))
            .map { "\($0.1.collectionName)" }
            .subscribe(with: self) { owner, value in
                transmissionList.onNext(value)
                let vc = DetailViewController()
                vc.nameTitle = value
                print(value,"hhuhuhuhuhu")
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
    func configureHierarcy() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        tableView.register(iTunesTableViewCell.self, forCellReuseIdentifier: iTunesTableViewCell.identifier)
        tableView.rowHeight = 100
    }
    func configureLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(5)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "검색"
        navigationController?.navigationBar.prefersLargeTitles = true
        searchBar.placeholder = "게임, 앱, 스토리 등"
        searchBar.backgroundImage = UIImage()
        tableView.backgroundColor = .green
    }
}
