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
    
    let disposeBag = DisposeBag()
    let viewModel = SignInViewModel()
    let viewModel2 = SignInViewModel2()
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        configure()
        
        //bind()
        bind2()
    }
    func bind2() {
        let input = SignInViewModel2.Input(tap: signInButton.rx.tap)
        let output = viewModel2.transform(input: input)
        
        output.text
            .map { joke in
                return joke.joke
            }
            .drive(with: self) { owner, value in
                owner.emailTextField.text = value
            }
            .disposed(by: disposeBag)
        //Driver >> drive
        //stream 공유(share), main thread 동작 보장, 오류 허용x
        output.text//asDriver(onErrorJustReturn: "")
            .map { joke in
                return "농담: \(joke.id)"
            }
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
    }
    func bind() {
        let input = SignInViewModel.Input(textEmail: emailTextField.rx.text, textPW: passwordTextField.rx.text, tap: signInButton.rx.tap)
        let output = viewModel.transform(input: input)

        Observable.combineLatest(output.validationEmail, output.validationPW) { $0 && $1 }//ouput
            .bind(with: self, onNext: { owner, value in
                owner.signInButton.isEnabled = value
                let color: UIColor = value ? .systemBlue : .black
                owner.signInButton.backgroundColor = color
            })
            .disposed(by: disposeBag)
        
        output.tap//signInButton.rx.tap//input,output
            .bind(onNext: { _ in
                let email = output.emailRelay.value//.value
                let pw = output.passwordRelay.value
                
                if let isPW = self.viewModel.account[email], isPW == pw {
                    self.showAlert(message: "로그인 성공!")
                } else {
                    self.showAlert(message: "이메일 또는 비밀번호가 잘못되었습니다.")
                }
            })
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
