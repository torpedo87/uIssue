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
  private let imgView: UIImageView = {
    let view = UIImageView()
    view.image = UIImage(named: "issue")
    view.contentMode = .scaleAspectFill
    return view
  }()
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
  
  private let gitHubBtn: UIButton = {
    let btn = UIButton()
    btn.setTitle("Forget your password?", for: .normal)
    btn.setTitleColor(UIColor.blue, for: .normal)
    return btn
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
    title = "LOGOUT"
    view.backgroundColor = UIColor.white
    view.addSubview(imgView)
    view.addSubview(idTextField)
    view.addSubview(passWordTextField)
    view.addSubview(logoutBtn)
    view.addSubview(gitHubBtn)
    
    imgView.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.width.height.equalTo(UIScreen.main.bounds.height / 4)
      make.bottom.equalTo(idTextField.snp.top).offset(-10)
    }
    
    idTextField.snp.makeConstraints({ (make) in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview().offset(-100)
      make.width.equalTo(UIScreen.main.bounds.width * 2 / 3)
      make.height.equalTo(UIScreen.main.bounds.height / 15)
    })
    
    passWordTextField.snp.makeConstraints({ (make) in
      make.centerX.equalToSuperview()
      make.top.equalTo(idTextField.snp.bottom).offset(10)
      make.width.height.equalTo(idTextField)
    })
    
    logoutBtn.snp.makeConstraints({ (make) in
      logoutBtn.sizeToFit()
      make.centerX.equalToSuperview()
      make.top.equalTo(passWordTextField.snp.bottom).offset(10)
    })
    
    gitHubBtn.snp.makeConstraints { (make) in
      gitHubBtn.sizeToFit()
      make.centerX.equalToSuperview()
      make.top.equalTo(logoutBtn.snp.bottom).offset(10)
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
      .flatMap { [unowned self] _ -> Observable<AuthService.Status> in
        self.viewModel.requestLogout(id: self.idTextField.text ?? "",
                                     password: self.passWordTextField.text ?? "")
      }
      .asDriver(onErrorJustReturn: AuthService.Status.unAuthorized("logout error"))
      .drive(onNext: { [unowned self] status in
        switch status {
        case .authorized: Navigator.shared.unwindTo(target: SplashViewController())
        case .unAuthorized(let value): self.showErrorMsg(message: value)
        }
      })
      .disposed(by: bag)
    
    gitHubBtn.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { _ in
        if let url = URL(string: "https://github.com/password_reset") {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
      })
      .disposed(by: bag)
  }
  
  func showErrorMsg(message: String) {
    let alert = UIAlertController(title: "Login Failed",
                                  message: message,
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK",
                                  style: .default,
                                  handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
}
