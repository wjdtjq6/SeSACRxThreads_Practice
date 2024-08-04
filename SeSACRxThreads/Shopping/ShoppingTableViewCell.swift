//
//  ShoppingTableViewCell.swift
//  SeSACRxThreads
//
//  Created by t2023-m0032 on 8/4/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class ShoppingTableViewCell: UITableViewCell {
    let uiView = UIView().then {
        $0.backgroundColor = .systemGray6
    }
    var leftButton = UIButton().then {
        $0.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
        $0.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        $0.tintColor = .black
    }
    var title = UILabel().then { _ in
    }
    var rightButton = UIButton().then {
        $0.setImage(UIImage(systemName: "star"), for: .normal)
        $0.setImage(UIImage(systemName: "star.fill"), for: .selected)
        $0.tintColor = .black
    }
    var disposeBag = DisposeBag()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureHierarchy()
        configureLayout()
        configureUI()
    }
    func configureHierarchy() {
        contentView.addSubview(uiView)
        contentView.addSubview(leftButton)
        contentView.addSubview(title)
        contentView.addSubview(rightButton)
    }
    func configureLayout() {
        uiView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(contentView)
            make.verticalEdges.equalTo(contentView).inset(5)
        }
        leftButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.leading.equalTo(uiView.snp.leading).offset(20)
        }
        title.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.leading.equalTo(leftButton.snp.trailing).offset(20)
            make.width.equalTo(150)
        }
        rightButton.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.trailing.equalTo(uiView.snp.trailing).inset(10)
        }
    }
    func configureUI() {
        uiView.backgroundColor = .systemGray6
        uiView.layer.cornerRadius = 10
    }
    override func prepareForReuse() {
            super.prepareForReuse()
            disposeBag = DisposeBag() // 셀 재사용 시 기존 disposeBag 초기화
        }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
