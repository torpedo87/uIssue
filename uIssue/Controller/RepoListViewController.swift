//
//  RepoListViewController.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RepoListViewController: UIViewController {
  private let bag = DisposeBag()
  fileprivate var viewModel = RepoListViewViewModel(account: UserNetworkManager.status)
  private var didSetupConstraints = false
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
    return btn
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    bindUI()
    view.setNeedsUpdateConstraints()
  }
  
  func setupView() {
    view.backgroundColor = UIColor.white
    
    view.addSubview(tableView)
    view.addSubview(settingBtn)
  }
  
  func bindUI() {
    viewModel.repoList.asDriver()
      .drive(onNext: { [weak self] _ in self?.tableView.reloadData() })
      .disposed(by: bag)
    
    settingBtn.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .map{ _ in true }
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { [weak self] _ in
        self?.presentSettingVC()
      })
      .disposed(by: bag)
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
  
  func presentSettingVC() {
    let settingViewController = SettingViewController()
    present(settingViewController, animated: true, completion: nil)
  }
  
}

extension RepoListViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.repoList.value.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.reuseIdentifier, for: indexPath) as? ListCell else { return UITableViewCell() }
    
    cell.configureCell(viewModel: viewModel, index: indexPath.row)
    return cell
  }
}

extension RepoListViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
  }
}
