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
    
    var data = ["A", "B", "C", "AB", "D", "ABC", "BBB", "EC", "SA", "AAAB", "ED", "F", "G", "H"]
    lazy var list = BehaviorSubject(value:data)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configure()
        setSearchController()
        bind()
    }
    
    func bind() {
        list
            .bind(to: tableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) { (row, element, cell) in
                
                cell.appNameLabel.text = element
                cell.appIconImageView.backgroundColor = .systemBlue
                cell.downloadButton.rx.tap
                    .subscribe(with: self) { owner, _ in
                        print("버튼 클릭")
                        owner.navigationController?.pushViewController(DetailViewController(), animated: true)
                    }
                    .disposed(by: cell.disposeBag) // 뷰 컨트롤러와 생명주기가 같지 않기 때문에 셀의 disposeBag을 사용해야함
            }
            .disposed(by: disposeBag)
        
        
        // searchbar
        searchBar.rx.searchButtonClicked
            .withUnretained(self)
            .withLatestFrom(searchBar.rx.text.orEmpty) { void, text in
                return text /*+ "조합해서 추가 가능"*/
            }
            .bind(with: self) {owner, value in
                owner.data.insert(value, at: 0)
                owner.list.onNext(owner.data)
                print("검색버튼 클릭")
            }
            .disposed(by: disposeBag)
        // value on chaged
        // 입력하자마자 통신 되는 것이 아니라 시간이 좀 지난 후 통신하고 싶을 때는?
        // -> debounce vs throttle
        
        
        //MARK: 실시간 검색기능
//        searchBar.rx.text.orEmpty
//            .debounce(.seconds(1), scheduler: MainScheduler.instance)
//            .distinctUntilChanged()// 값이 같다면 다시 호출하지 마
//            .bind(with: self) { owner, value in
//                print("실시간 검색", value)
//                let result = value.isEmpty ? owner.data : owner.data.filter { $0.contains(value)} //원본 데이터를 건들지 않고 새로운 배열을 만듬
//                owner.list.onNext(result) // onnext 값 교체
//                print(self.list)
//            }
//            .disposed(by: disposeBag)
    }
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
//#if DEBUG
//import SwiftUI
//struct ViewControllerRepresentable_DBVC: UIViewControllerRepresentable {
//
//    func updateUIViewController(_ uiView: UIViewController,context: Context) {
//        // leave this empty
//    }
//    @available(iOS 13.0.0, *)
//    func makeUIViewController(context: Context) -> UIViewController{
//        SearchViewController()
//    }
//}
//@available(iOS 13.0, *)
//struct ViewControllerRepresentable_DBVC_PreviewProvider: PreviewProvider {
//    static var previews: some View {
//        Group {
//            ViewControllerRepresentable_DBVC()
//                .ignoresSafeArea()
//                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
//        }
//
//    }
//} #endif
