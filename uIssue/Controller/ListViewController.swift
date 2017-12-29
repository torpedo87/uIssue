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
  private var issueList: [Issue] = []
  private lazy var tableView: UITableView = {
    let view = UITableView()
    view.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
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
    fetchIssueData()
    view.setNeedsUpdateConstraints()
  }
  
  func fetchIssueData() {
    guard let me = UserDefaults.standard.loadMe() else { return }
    IssueDataManager.fetchIssueList(userId: me.getId(), userPassword: me.getPassword(), filter: Filter.created.rawValue, state: State.open.rawValue) { (issueArr) in
      if let issueArr = issueArr {
        self.issueList = issueArr
        self.tableView.reloadData()
      }
    }
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
        make.height.equalTo(50)
        make.width.equalTo(100)
      })
      
      didSetupConstraints = true
    }
    
    super.updateViewConstraints()
  }
  
  @objc func logoutBtnDidTap(_ sender: UIButton) {
    
    guard let me = UserDefaults.standard.loadMe() else { fatalError() }
    
    UserNetworkManager.logout(userId: me.getId(), userPassword: me.getPassword(), tokenId: me.getTokenId()) { (statusCode) in
      if statusCode == 204 {
        print("logout success")
        UserDefaults.standard.removeMe()
        DispatchQueue.main.async {
          self.dismiss(animated: true, completion: nil)
        }
        
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
    return issueList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.reuseIdentifier, for: indexPath) as? ListCell else { return UITableViewCell() }
    cell.configureCell(issue: issueList[indexPath.row])
    return cell
  }
}

extension ListViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
}
