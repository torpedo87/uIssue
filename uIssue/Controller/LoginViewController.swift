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
    btn.backgroundColor = UIColor.blue
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
    loginBtn.rx.controlEvent(UIControlEvents.touchUpInside)
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap { [weak self] _ -> Single<(Int, String)> in
        UserNetworkManager
            .login(userId: self!.idTextField.text!, userPassword: self!.passWordTextField.text!)
      }
      .asObservable()
      .observeOn(MainScheduler.instance)
      .bind(onNext: { [weak self] tuple in
        if tuple.1 != "error" {
          let me = Me(id: self!.idTextField.text!, password: self!.passWordTextField.text!, tokenId: tuple.0, token: tuple.1)
          UserDefaults.standard.saveMe(user: me)
          self!.presentListVC()
        } else {
          print("error")
        }
      })
      .disposed(by: bag)
    
//      .asDriver(onErrorJustReturn: (-1, "error"))
//      .drive(onNext: { [weak self] (tuple) in
//        if tuple.1 != "error" {
//          let me = Me(id: self!.idTextField.text!, password: self!.passWordTextField.text!, tokenId: tuple.0, token: tuple.1)
//          UserDefaults.standard.saveMe(user: me)
//          self!.presentListVC()
//        } else {
//          print("error")
//        }
//
//      })
//      .disposed(by: bag)
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
  
  func presentListVC() {
    let listViewController = ListViewController()
    present(listViewController, animated: true, completion: nil)
  }
  
  func checkLoginSession() {
    let me = UserDefaults.standard.loadMe()
    
    if me != nil {
      self.presentListVC()
    }
  }
}
