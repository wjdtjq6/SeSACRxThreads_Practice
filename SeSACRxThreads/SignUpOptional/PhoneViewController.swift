//
//  PhoneViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa
/*
 1.첫 화면 진입 시 010을 textField에 바로 띄움
 2.textField에는 숫자만 들어갈 수 있고, 10자 이상이어야 함
 3.textField 조건이 맞지 않을 경우, PasswordViewController Logic처럼 처리
 4.조건에 맞아 버튼 누르면 push
 */
class PhoneViewController: UIViewController {
   
    let phoneTextField = SignTextField(placeholderText: "연락처를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        configureLayout()
        phoneTextField.keyboardType = .numberPad
        bind()
    }

    func bind() {
        //1.
        let validInt = BehaviorSubject(value: "010")//<Int>(value: 010)
        validInt
            .bind(to: phoneTextField.rx.text)
            .disposed(by: disposeBag)
        //2.
        let validation = phoneTextField.rx.text.orEmpty
            .map { $0.count >= 10 }
        //3.
        validation
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        //4.
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(NicknameViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    func configureLayout() {
        view.addSubview(phoneTextField)
        view.addSubview(nextButton)
         
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(phoneTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
