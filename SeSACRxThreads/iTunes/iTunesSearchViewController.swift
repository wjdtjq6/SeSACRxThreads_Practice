//
//  iTunesSearchViewController.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/9/24.
//

import UIKit
import SnapKit

class iTunesSearchViewController: UIViewController {
    let searchBar = UISearchBar()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarcy()
        configureLayout()
        configureUI()
    }
    func configureHierarcy() {
        view.addSubview(searchBar)
    }
    func configureLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
    }
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "검색"
        navigationController?.navigationBar.prefersLargeTitles = true
        searchBar.placeholder = "게임, 앱, 스토리 등"
        searchBar.backgroundImage = UIImage()
    }
}
