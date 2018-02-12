//
//  LoginViewController.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 27..
//  Copyright © 2017년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
  
  private let bag = DisposeBag()
  private var viewModel: LoginViewViewModel!
  private let idTextField: UITextField = {
    let txtField = UITextField()
    txtField.placeholder = "please enter id"
    txtField.layer.borderColor = UIColor.blue.cgColor
    txtField.layer.borderWidth = 0.5
    return txtField
  }()
  
  private let passWordTextField: UITextField = {
    let txtField = UITextField()
    txtField.placeholder = "please enter password"
    txtField.layer.borderColor = UIColor.blue.cgColor
    txtField.isSecureTextEntry = true
    txtField.layer.borderWidth = 0.5
    return txtField
  }()
  
  private let loginBtn: UIButton = {
    let btn = UIButton()
    btn.setTitle("Login", for: UIControlState.normal)
    btn.isEnabled = false
    btn.setTitleColor(UIColor.blue, for: UIControlState.normal)
    btn.setTitleColor(UIColor.gray, for: UIControlState.disabled)
    return btn
  }()
  
  private let messageLabel: UILabel = {
    let label = UILabel()
    label.isHidden = true
    label.sizeToFit()
    label.textAlignment = .center
    return label
  }()
  
  static func createWith(viewModel: LoginViewViewModel) -> LoginViewController {
    return {
      $0.viewModel = viewModel
      return $0
    }(LoginViewController())
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    bindUI()
  }
  
  func setupView() {
    title = "Login"
    view.backgroundColor = UIColor.white
    view.addSubview(idTextField)
    view.addSubview(passWordTextField)
    view.addSubview(loginBtn)
    view.addSubview(messageLabel)
    
    idTextField.snp.makeConstraints({ (make) in
      make.center.equalToSuperview()
      make.width.equalTo(200)
      make.height.equalTo(50)
    })
    
    passWordTextField.snp.makeConstraints({ (make) in
      make.centerX.equalToSuperview()
      make.top.equalTo(idTextField.snp.bottom).offset(10)
      make.width.height.equalTo(idTextField)
    })
    
    loginBtn.snp.makeConstraints({ (make) in
      make.centerX.equalToSuperview()
      make.top.equalTo(passWordTextField.snp.bottom).offset(10)
      make.width.height.equalTo(passWordTextField)
    })
    
    messageLabel.snp.makeConstraints({ (make) in
      make.centerX.equalToSuperview()
      make.top.equalTo(loginBtn.snp.bottom).offset(10)
      make.width.height.equalTo(passWordTextField)
    })
  }
  
  func bindUI() {
    
    //키보드에 따라 버튼 오르락 내리락
    NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillShow)
      .asObservable()
      .subscribe(onNext: { [weak self] noti in
        self?.loginBtn.keyboardWillChange(noti)
      })
      .disposed(by: bag)
    NotificationCenter.default.rx.notification(Notification.Name.UIKeyboardWillHide)
      .asObservable()
      .subscribe(onNext: { [weak self] noti in
        self?.loginBtn.keyboardWillChange(noti)
      })
      .disposed(by: bag)
    
    //사용자 입력값을 뷰모델에 전달
    idTextField.rx.text.orEmpty
      .bind(to: viewModel.idTextInput)
      .disposed(by: bag)
    passWordTextField.rx.text.orEmpty
      .bind(to: viewModel.pwdTextInput)
      .disposed(by: bag)
    
    
    //뷰모델에서 가공된 결과를 받아서 바인딩
    viewModel.validate
      .drive(loginBtn.rx.isEnabled)
      .disposed(by: bag)
    
    //로그인 버튼클릭시 토큰 요청해서 성공하면 화면이동, 실패시 에러메시지
    loginBtn.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<AuthService.Status> in
        (self?.viewModel.requestLogin(id: (self?.idTextField.text!)!,
                                      password: (self?.passWordTextField.text!)!))!
      }
      .asDriver(onErrorJustReturn: AuthService.Status.unAuthorized("login error"))
      .drive(onNext: { [weak self] status in
        switch status {
        case .authorized: do {
          Navigator.shared.show(destination: .repoList, sender: self!)
          }
        case .unAuthorized(let value): self?.showErrorMsg(message: value)
        }
      })
      .disposed(by: bag)
    
  }
  
  func showErrorMsg(message: String) {
    messageLabel.text = message
    messageLabel.isHidden = false
    Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
      self.messageLabel.isHidden = true
    }
  }
  
}
