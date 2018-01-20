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
  private var didSetupConstraints = false
  lazy var logoutBtn: UIButton = {
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
    view.addSubview(logoutBtn)
    
  }
  
  override func updateViewConstraints() {
    if !didSetupConstraints {
      
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
      
      didSetupConstraints = true
    }
    
    super.updateViewConstraints()
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
      .drive(logoutBtn.rx.isEnabled).disposed(by: bag)
    
    logoutBtn.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<UserNetworkManager.Status> in
        UserNetworkManager
          .removeToken(userId: (self?.idTextField.text!)!, userPassword: (self?.passWordTextField.text!)!)
      }
      .asDriver(onErrorJustReturn: UserNetworkManager.Status.unAuthorized)
      .drive(onNext: { status in
        if status == UserNetworkManager.Status.authorized {
          guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
          appDelegate.unwindToLoginVC()
        } else {
          print("cannot logout")
        }
      })
      .disposed(by: bag)
  }
  
}
