//
//  BirthdayViewController.swift
//  SeSACRxThreads
//
//  Created by jack on 2023/10/30.
//
 
import UIKit
import SnapKit
import RxSwift
import RxCocoa
/*
 1.화면 진입 시 오늘 날짜가 데이트피커와 레이블에 뜸
 2.데이트피커에서 선택한 날짜로 나이 계산 시, 만 17세 이상이 아니라면 infoLabel에 "만 17세 이상만 가입 가능합니다" 빨간색. 이 때 버튼은 lightGrey 클릭x
 3.조건이 만족되면 infoLabel은 "가입 가능한 나이입니다"는 텍스트와 파란색글씨로. 이 때 버튼은 Blue 클릭o
 4.버튼 클릭 시 "완료"가 되었다는 Alert
 */
class BirthdayViewController: UIViewController {
    
    let birthDayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    let infoLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.text = "만 17세 이상만 가입 가능합니다."
        return label
    }()
    let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10 
        return stack
    }()
    let yearLabel: UILabel = {
       let label = UILabel()
        label.text = "2023년"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    let monthLabel: UILabel = {
       let label = UILabel()
        label.text = "33월"
        label.textColor = Color.black
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    let dayLabel: UILabel = {
    let label = UILabel()
    label.text = "99일"
    label.textColor = Color.black
    label.snp.makeConstraints {
        $0.width.equalTo(100)
    }
    return label
}()
    let nextButton = PointButton(title: "가입하기")
    
    var year = BehaviorRelay(value: 1996)
    var month = BehaviorRelay(value: 6)
    var day = BehaviorRelay(value: 1)
    let nColor = Observable.just(UIColor.black)
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.white
        configureLayout()
        bind()
    }
    func bind() {
        //1.
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let yearStr = yearFormatter.string(from: Date.now)
        year = BehaviorRelay(value: Int(yearStr)!)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "M"
        let monthStr = monthFormatter.string(from: Date.now)
        month = BehaviorRelay(value: Int(monthStr)!)
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        let dayStr = dayFormatter.string(from: Date.now)
        day = BehaviorRelay(value:Int(dayStr)!)
        year
            .map { "\($0)년" }
            .bind(to: yearLabel.rx.text)
            .disposed(by: disposeBag)
        month
            .map{ "\($0)월" }
            .bind(to: monthLabel.rx.text)
            .disposed(by: disposeBag)
        day
            .map{ "\($0)일" }
            .bind(to: dayLabel.rx.text)
            .disposed(by: disposeBag)
        //2,3.
        birthDayPicker.rx.date
            .bind(with: self) { owner, date in
                let component = Calendar.current.dateComponents([.day,.month,.year], from: date)
                owner.year.accept(component.year!)
                owner.month.accept(component.month!)
                owner.day.accept(component.day!)
            }
        let validation = birthDayPicker.rx.date
            .map { date -> Bool in
                let component = Calendar.current.dateComponents([.year], from: date, to: Date())
                guard let age = component.year else { return false }
                return age >= 17
            }
        validation
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        validation
            .bind(with: self) { owner, value in
                let labelColor: UIColor = value ? .systemBlue : .systemRed
                owner.infoLabel.textColor = labelColor
                let labelText: String = value ? "가입 가능한 나이입니다" : "만 17세 이상만 가입 가능합니다."
                owner.infoLabel.text = labelText
                
                let buttonColor: UIColor = value ? .systemBlue : .lightGray
                owner.nextButton.backgroundColor = buttonColor
            }
        //4.
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                let alert = UIAlertController(title: "완료", message: nil, preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default)
                alert.addAction(ok)
                self.present(alert, animated: true)
            }
    }
    func configureLayout() {
        view.addSubview(infoLabel)
        view.addSubview(containerStackView)
        view.addSubview(birthDayPicker)
        view.addSubview(nextButton)
 
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            $0.centerX.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(30)//offset 추가함
            $0.centerX.equalToSuperview().offset(30)
        }
        
        [yearLabel, monthLabel, dayLabel].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        birthDayPicker.snp.makeConstraints {
            $0.top.equalTo(containerStackView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
   
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(birthDayPicker.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
}
