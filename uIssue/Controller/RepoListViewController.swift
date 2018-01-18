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
  lazy var settingBtn: UIButton = {
    let btn = UIButton()
    btn.setTitle("Setting", for: UIControlState.normal)
    btn.backgroundColor = UIColor.blue
    btn.addTarget(self, action: #selector(RepoListViewController.setttingBtnDidTap(_:)), for: UIControlEvents.touchUpInside)
    return btn
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    fetchRepoList()
    
    view.setNeedsUpdateConstraints()
  }
  
  func fetchRepoList() {
    
    IssueDataManager.fetchRepoList(sort: IssueDataManager.Sort.created.rawValue) { [weak self] (repos) in
      if let repos = repos {
        self?.repoList = repos
        self?.tableView.reloadData()
      }
    }
  }
  
  func setupView() {
    view.backgroundColor = UIColor.white
    
    view.addSubview(tableView)
    view.addSubview(settingBtn)
  }
  
  override func updateViewConstraints() {
    if !didSetupConstraints {
      
      tableView.snp.makeConstraints({ (make) in
        make.left.right.equalToSuperview()
        make.top.equalToSuperview().offset(50)
        make.bottom.equalToSuperview().offset(-100)
      })
      
      settingBtn.snp.makeConstraints({ (make) in
        settingBtn.sizeToFit()
        make.right.bottom.equalToSuperview()
      })
      
      didSetupConstraints = true
    }
    
    super.updateViewConstraints()
  }
  
  @objc func setttingBtnDidTap(_ sender: UIButton) {
    let settingViewController = SettingViewController()
    present(settingViewController, animated: true, completion: nil)
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
