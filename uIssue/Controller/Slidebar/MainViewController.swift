//
//  MainViewController.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 22..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
  let menuButton: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "menu"), for: .normal)
    return btn
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  func setupView() {
    view.backgroundColor = UIColor.yellow
    view.addSubview(menuButton)
    
    menuButton.snp.makeConstraints { (make) in
      menuButton.sizeToFit()
      make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(5)
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
    }
  }
}
