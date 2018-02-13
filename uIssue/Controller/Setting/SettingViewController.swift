//
//  SettingViewController.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 17..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingViewController: UIViewController {
  
  private let bag = DisposeBag()
  private var viewModel: SettingViewViewModel!
  private let logoutBtn: UIButton = {
    let btn = UIButton()
    btn.setTitle("Logout", for: UIControlState.normal)
    btn.isEnabled = false
    btn.setTitleColor(UIColor.blue, for: UIControlState.normal)
    btn.setTitleColor(UIColor.gray, for: UIControlState.disabled)
    return btn
  }()
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
  
  private let messageLabel: UILabel = {
    let label = UILabel()
    label.isHidden = true
    label.sizeToFit()
    label.textAlignment = .center
    return label
  }()
  
  static func createWith(viewModel: SettingViewViewModel) -> SettingViewController {
    return {
      $0.viewModel = viewModel
      return $0
      }(SettingViewController())
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    bindUI()
  }
  
  func setupView() {
    title = "Setting"
    view.backgroundColor = UIColor.white
    view.addSubview(idTextField)
    view.addSubview(passWordTextField)
    view.addSubview(logoutBtn)
    view.addSubview(messageLabel)
    
    idTextField.snp.makeConstraints({ (make) in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-100)
      make.width.equalTo(UIScreen.main.bounds.width / 2)
      make.height.equalTo(UIScreen.main.bounds.height / 15)
    })
    
    passWordTextField.snp.makeConstraints({ (make) in
      make.centerX.equalToSuperview()
      make.top.equalTo(idTextField.snp.bottom).offset(10)
      make.width.height.equalTo(idTextField)
    })
    
    logoutBtn.snp.makeConstraints { (make) in
      logoutBtn.sizeToFit()
      make.top.equalTo(passWordTextField.snp.bottom).offset(10)
      make.centerX.equalToSuperview()
    }
    
    messageLabel.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.top.equalTo(logoutBtn.snp.bottom).offset(10)
      make.width.height.equalTo(passWordTextField)
    }
  }
  
  func bindUI() {
    //사용자 입력값을 뷰모델에 전달
    idTextField.rx.text.orEmpty
      .bind(to: viewModel.idTextInput)
      .disposed(by: bag)
    
    passWordTextField.rx.text.orEmpty
      .bind(to: viewModel.pwdTextInput)
      .disposed(by: bag)
    
    
    //뷰모델에서 가공된 결과를 받아서 바인딩
    viewModel.validate
      .drive(logoutBtn.rx.isEnabled)
      .disposed(by: bag)
    
    //로그아웃 성공하면 화면이동, 싪패시 에러메시지
    logoutBtn.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<AuthService.Status> in
        (self?.viewModel.requestLogout(id: (self?.idTextField.text)!,
                                       password: (self?.passWordTextField.text)!))!
      }
      .asDriver(onErrorJustReturn: AuthService.Status.unAuthorized("logout error"))
      .drive(onNext: { [weak self] status in
        switch status {
        case .authorized: Navigator.shared.unwindTo(target: SplashViewController())
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
