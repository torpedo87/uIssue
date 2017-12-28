//
//  ListViewController.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
  
  private var didSetupConstraints = false
  private lazy var tableView: UITableView = {
    let view = UITableView()
    view.dataSource = self
    view.delegate = self
    return view
  }()
  
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
    view.backgroundColor = UIColor.white
    
    view.addSubview(tableView)
    view.addSubview(logoutBtn)
  }
  
  override func updateViewConstraints() {
    if !didSetupConstraints {
      
      tableView.snp.makeConstraints({ (make) in
        make.left.right.equalToSuperview()
        make.top.equalToSuperview().offset(50)
        make.bottom.equalToSuperview().offset(-100)
      })
      logoutBtn.snp.makeConstraints({ (make) in
        make.right.bottom.equalToSuperview().offset(-10)
        make.width.height.equalTo(50)
      })
      
      didSetupConstraints = true
    }
    
    super.updateViewConstraints()
  }
  
  @objc func logoutBtnDidTap(_ sender: UIButton) {
    let user = UserDefaults.standard.loadUser()
    UserNetworkManager.logout(userId: user.getId(), userPassword: user.getPassword(), tokenId: user.getTokenId()) { (statusCode) in
      if statusCode == 204 {
        print("logout success")
      } else {
        print("logout fail")
      }
    }
  }
  
}

extension ListViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
}

extension ListViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
}
