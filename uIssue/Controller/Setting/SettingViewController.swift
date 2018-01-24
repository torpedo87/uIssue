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
  private lazy var logoutBtn: UIButton = {
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
    view.setNeedsUpdateConstraints()
  }
  
  func setupView() {
    title = "Setting"
    view.backgroundColor = UIColor.white
    view.addSubview(idTextField)
    view.addSubview(passWordTextField)
    view.addSubview(logoutBtn)
    
    logoutBtn.snp.makeConstraints({ (make) in
      make.right.bottom.equalToSuperview().offset(-10)
      make.height.equalTo(50)
      make.width.equalTo(100)
    })
    
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
    
    logoutBtn.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<AuthService.Status> in
        (self?.viewModel.requestLogout(id: (self?.idTextField.text)!,
                                       password: (self?.passWordTextField.text)!))!
      }
      .asDriver(onErrorJustReturn: AuthService.Status.unAuthorized("logout error"))
      .drive(onNext: { status in
        switch status {
        case .authorized: Navigator.shared.unwindTo(target: SplashViewController())
        case .unAuthorized(let value): print(value)
        }
      })
      .disposed(by: bag)
  }
  
}
