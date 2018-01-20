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
  fileprivate var viewModel = RepoListViewViewModel()
  private var didSetupConstraints = false
  private lazy var tableView: UITableView = {
    let view = UITableView()
    view.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
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
    bindTableView()
    view.setNeedsUpdateConstraints()
  }
  
  func setupView() {
    title = "Repository List"
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
        self?.pushSettingVC()
      })
      .disposed(by: bag)
  }
  
  func bindTableView() {
    //datasource
    viewModel.repoList.asObservable()
      .bind(to: tableView.rx.items) {
        [weak self] (tableView: UITableView, index: Int, element: Repository) in
        let cell = ListCell(style: .default, reuseIdentifier: ListCell.reuseIdentifier)
        cell.configureCell(viewModel: (self?.viewModel)!, index: index)
        return cell
    }
    .disposed(by: bag)
    
    //delegate
    tableView.rx
      .itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
        self?.pushIssueListVC()
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
  
  func pushSettingVC() {
    let settingViewController = SettingViewController()
    navigationController?.pushViewController(settingViewController, animated: true)
  }
  
  func pushIssueListVC() {
    let issueListVC = IssueListViewController()
    navigationController?.pushViewController(issueListVC, animated: true)
  }
  
}
