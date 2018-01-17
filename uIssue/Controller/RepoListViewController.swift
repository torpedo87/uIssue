//
//  RepoListViewController.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import UIKit

class RepoListViewController: UIViewController {
  
  private var didSetupConstraints = false
  private var repoList: [Repository] = []
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
    fetchRepoList()
    
    view.setNeedsUpdateConstraints()
  }
  
  func fetchRepoList() {
    guard let token = UserDefaults.standard.loadToken() else { return }
    IssueDataManager.fetchRepoList(token: token.token, sort: Sort.created.rawValue) { [weak self] (repos) in
      if let repos = repos as? [Repository] {
        self?.repoList = repos
        self?.tableView.reloadData()
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

extension RepoListViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return repoList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.reuseIdentifier, for: indexPath) as? ListCell else { return UITableViewCell() }
    cell.configuerCell(repo: repoList[indexPath.row])
    return cell
  }
}

extension RepoListViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
}
