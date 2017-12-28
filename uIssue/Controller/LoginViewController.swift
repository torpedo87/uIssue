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
    txtField.layer.borderWidth = 0.5
    return txtField
  }()
  
  private lazy var loginBtn: UIButton = {
    let btn = UIButton()
    btn.setTitle("Login", for: UIControlState.normal)
    btn.backgroundColor = UIColor.blue
    btn.addTarget(self, action: #selector(loginBtnDidTap(_:)), for: UIControlEvents.touchUpInside)
    return btn
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.yellow
    
    setupView()
    
    view.setNeedsUpdateConstraints()
  }
  
  func setupView() {
    view.addSubview(idTextField)
    view.addSubview(passWordTextField)
    view.addSubview(loginBtn)
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
  
  @objc func loginBtnDidTap(_ sender: UIButton) {
    guard let userId = idTextField.text else { return }
    guard let userPassword = passWordTextField.text else { return }
    UserNetworkManager.shared.login(userId: userId, userPassword: userPassword) { (success, token) in
      if success {
        print("login success", token)
      } else {
        print("login failed")
      }
    }
  }
}
