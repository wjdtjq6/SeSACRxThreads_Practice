//
//  SignInViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SignInViewController: UIViewController {

    let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    let signInButton = PointButton(title: "로그인")
    let signUpButton = UIButton()
    let emailRelay = BehaviorRelay<String>(value: "")
    let passwordRelay = BehaviorRelay<String>(value: "")
    let viewModel = SignInViewModel()
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        configure()
        
        bind()
    }
    
    func bind() {
        
        let validationEmail = emailTextField.rx.text.orEmpty
            .map({ $0.count > 0 })
            
        emailTextField.rx.text.orEmpty
            .bind(to: emailRelay)
            .disposed(by: disposeBag)
                    
        let validationPW = passwordTextField.rx.text.orEmpty
            .map { $0.count > 0 }
        
        passwordTextField.rx.text.orEmpty
            .bind(to: passwordRelay)
            .disposed(by: disposeBag)

        Observable.combineLatest(validationEmail, validationPW) { $0 && $1 }
            .bind(with: self, onNext: { owner, value in
                owner.signInButton.isEnabled = value
                let color: UIColor = value ? .systemBlue : .black
                owner.signInButton.backgroundColor = color
            })
            .disposed(by: disposeBag)
        
        signInButton.rx.tap
            .subscribe { _ in
                let email = self.emailRelay.value
                let pw = self.passwordRelay.value
                
                if let isPW = self.viewModel.account[email], isPW == pw {
                    self.showAlert(message: "로그인 성공!")
                } else {
                    self.showAlert(message: "이메일 또는 비밀번호가 잘못되었습니다.")
                }
            }
            .disposed(by: disposeBag)
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let check = UIAlertAction(title: "확인", style: .default)
        alert.addAction(check)
        present(alert, animated: true)
    }
    @objc func signUpButtonPressed() {
        navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
    func configure() {
        signUpButton.setTitle("회원이 아니십니까?", for: .normal)
        signUpButton.setTitleColor(Color.black, for: .normal)
        signUpButton.addTarget(self, action: #selector(signUpButtonPressed), for: .touchUpInside)
    }
    
    func configureLayout() {
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpButton)
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        signInButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(signInButton.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    

}
