//
//  SettingViewController.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 17..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
  
  private var didSetupConstraints = false
  private lazy var logoutBtn: UIButton = {
    let btn = UIButton()
    btn.setTitle("LOGOUT", for: UIControlState.normal)
    btn.backgroundColor = UIColor.blue
    btn.addTarget(self, action: #selector(logoutBtnDidTap(_:)), for: UIControlEvents.touchUpInside)
    return btn
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    view.setNeedsUpdateConstraints()
  }
  
  func setupView() {
    view.addSubview(logoutBtn)
  }
  
  override func updateViewConstraints() {
    if !didSetupConstraints {
      
      logoutBtn.snp.makeConstraints({ (make) in
        make.right.bottom.equalToSuperview().offset(-10)
        make.height.equalTo(50)
        make.width.equalTo(100)
      })
      
      didSetupConstraints = true
    }
    
    super.updateViewConstraints()
  }
  
  @objc func logoutBtnDidTap(_ sender: UIButton) {
    
    UserDefaults.standard.removeLocalToken()
//    UserNetworkManager.logout(userId: me.getId(), userPassword: me.getPassword(), tokenId: me.getTokenId()) { (statusCode) in
//      if statusCode == 204 {
//        print("logout success")
//        UserDefaults.standard.removeLocalToken()
//        DispatchQueue.main.async {
//          self.dismiss(animated: true, completion: nil)
//        }
//
//      } else {
//        print("logout fail")
//      }
//    }
  }
}
