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
  private let viewModel = LoginViewViewModel()
  private var didSetupConstraints = false
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
  
  lazy var loginBtn: UIButton = {
    let btn = UIButton()
    btn.setTitle("Login", for: UIControlState.normal)
    btn.isEnabled = false
    btn.setTitleColor(UIColor.blue, for: UIControlState.normal)
    btn.setTitleColor(UIColor.gray, for: UIControlState.disabled)
    return btn
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    bindUI()
    view.setNeedsUpdateConstraints()
  }
  
  func setupView() {
    view.backgroundColor = UIColor.white
    view.addSubview(idTextField)
    view.addSubview(passWordTextField)
    view.addSubview(loginBtn)
  }
  
  func bindUI() {
    
    //driver인데 왜 디스패치큐를 넣어줘야 작동할까...
    UserNetworkManager.status
      .debug("dddddd")
      .drive(onNext: { [weak self] (status) in
        if status == UserNetworkManager.Status.authorized {
          DispatchQueue.main.async {
            self?.presentRepoListVC()
          }
        }
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

    loginBtn.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<UserNetworkManager.Status> in
        (self?.viewModel.requestLogin(id: (self?.idTextField.text!)!, password: (self?.passWordTextField.text!)!))!
      }
      .asDriver(onErrorJustReturn: UserNetworkManager.Status.unAuthorized)
      .drive(onNext: { [weak self] status in
        if status == UserNetworkManager.Status.authorized {
          self?.presentRepoListVC()
        } else {
          print("cannot login")
        }
      })
      .disposed(by: bag)
  }
  
  override func updateViewConstraints() {
    if !didSetupConstraints {
      
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
      didSetupConstraints = true
    }
    super.updateViewConstraints()
  }
  
  func presentRepoListVC() {
    let repoListViewController = RepoListViewController()
    present(repoListViewController, animated: true, completion: nil)
  }
  
}
