//
//  NicknameViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class NicknameViewController: UIViewController {
   
    let nicknameTextField = SignTextField(placeholderText: "닉네임을 입력해주세요")
    let nextButton = PointButton(title: "다음")
    let descriptionLabel = UILabel()
    let validText = Observable.just("특수문자(`,~,$,^,+,=,|),숫자,공백을 제외하고 6자 이하로 입력해주세요")
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
       
        bind()
        
    }
    
    func bind() {
        let validation = nicknameTextField.rx.text.orEmpty
            //.map { $0.count < 4 && Int($0) == nil }
            .map { text in
                text.count >= 1 && text.count < 6 && text.filter{ $0.isNumber }.isEmpty && text.filter{ $0.isSymbol }.isEmpty && text.filter{ $0.isWhitespace }.isEmpty
            }
        validation
            .bind(to: nextButton.rx.isEnabled, descriptionLabel.rx.isHidden)
            .disposed(by: disposeBag)
        validation
            .bind(with: self) { owner, value in
                owner.nextButton.isEnabled = value
                owner.descriptionLabel.isHidden = value
            }
        validText
            .bind(to: descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        nextButton.rx.tap
            .bind(with: self) { owner, value in
                owner.navigationController?.pushViewController(BirthdayViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func configureLayout() {
        view.addSubview(nicknameTextField)
        view.addSubview(descriptionLabel)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        view.addSubview(nextButton)
        nicknameTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(15)
            make.top.equalTo(nicknameTextField.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(descriptionLabel.snp.bottom)//.offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
