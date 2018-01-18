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
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    checkLoginSession()
  }
  
  func setupView() {
    view.backgroundColor = UIColor.white
    view.addSubview(idTextField)
    view.addSubview(passWordTextField)
    view.addSubview(loginBtn)
  }
  
  func bindUI() {
    
    let idInput = idTextField.rx.controlEvent(UIControlEvents.editingChanged).asObservable()
      .map { [weak self] _ -> Bool in
        if let input = self?.idTextField.text, input.isEmpty {
          return false
        }
        return true
    }
    
    let pwdInput = passWordTextField.rx.controlEvent(UIControlEvents.editingChanged).asObservable()
      .map { [weak self] _ -> Bool in
        if let input = self?.passWordTextField.text, input.isEmpty {
          return false
        }
        return true
    }
    
    Observable.combineLatest(idInput, pwdInput)
      .map{ tuple -> Bool in
        if tuple.0 == true && tuple.1 == true {
          return true
        }
        return false
      }
      .asDriver(onErrorJustReturn: false)
      .drive(loginBtn.rx.isEnabled).disposed(by: bag)
    
    
    loginBtn.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<UserNetworkManager.Status> in
        UserNetworkManager
          .requestToken(userId: (self?.idTextField.text)!, userPassword: (self?.passWordTextField.text)!)
      }
      .asDriver(onErrorJustReturn: UserNetworkManager.Status.unAuthorizable)
      .drive(onNext: { [weak self] status in
        if status == UserNetworkManager.Status.authorizable {
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
  
  func checkLoginSession() {
    let token = UserDefaults.standard.loadToken()
    
    if token != nil {
      self.presentRepoListVC()
    }
  }
}
