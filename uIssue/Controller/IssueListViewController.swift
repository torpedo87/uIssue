//
//  IssueListViewController.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 20..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class IssueListViewController: UIViewController {
  private let bag = DisposeBag()
  var viewModel: IssueListViewViewModel!
  private var didSetupConstraints = false
  private lazy var tableView: UITableView = {
    let view = UITableView()
    view.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
    return view
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    bindUI()
    bindTableView()
    view.setNeedsUpdateConstraints()
  }
  
  func setupView() {
    title = "Issue List"
    view.backgroundColor = UIColor.white
    view.addSubview(tableView)
  }
  
  override func updateViewConstraints() {
    if !didSetupConstraints {
      
      tableView.snp.makeConstraints({ (make) in
        make.left.right.equalToSuperview()
        make.top.equalToSuperview().offset(50)
        make.bottom.equalToSuperview().offset(-100)
      })
      
      didSetupConstraints = true
    }
    
    super.updateViewConstraints()
  }
  
  func bindUI() {
    viewModel.issueList.asDriver()
      .drive(onNext: { [weak self] _ in self?.tableView.reloadData() })
      .disposed(by: bag)
  }
  
  func bindTableView() {
    //datasource
    viewModel.issueList.asObservable()
      .bind(to: tableView.rx.items) {
        [weak self] (tableView: UITableView, index: Int, element: Issue) in
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
        
      })
      .disposed(by: bag)
  }
  
}
