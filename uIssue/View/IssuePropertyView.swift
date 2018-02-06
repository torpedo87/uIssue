//
//  IssuePropertyView.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 6..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct LabelItem {
  var label: IssueService.Label
  var isChecked: Bool
}

struct AssigneeItem {
  var user: User
  var isChecked: Bool
}

class IssuePropertyView: UIView {
  
  private var viewModel: PropertySettable!
  private let bag = DisposeBag()
  
  private lazy var labelLabel: UILabel = {
    let view = UILabel()
    view.text = "LABEL"
    view.backgroundColor = UIColor(hex: "F1F8FF")
    return view
  }()
  
  private lazy var userLabel: UILabel = {
    let view = UILabel()
    view.text = "ASSIGNEE"
    view.backgroundColor = UIColor(hex: "F1F8FF")
    return view
  }()
  
  private lazy var labelTableView: UITableView = {
    let table = UITableView()
    table.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
    table.rowHeight = 50
    table.allowsMultipleSelection = true
    return table
  }()
  
  private lazy var assigneeTableView: UITableView = {
    let table = UITableView()
    table.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
    table.rowHeight = 50
    table.allowsMultipleSelection = true
    return table
  }()
  
  init(viewModel: PropertySettable) {
    self.viewModel = viewModel
    super.init(frame: CGRect.zero)
    setupView()
    bindTableView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupView() {
    addSubview(labelLabel)
    addSubview(userLabel)
    addSubview(labelTableView)
    addSubview(assigneeTableView)
    
    labelLabel.snp.makeConstraints { (make) in
      make.top.left.equalToSuperview()
      make.height.equalTo(50)
      make.width.equalTo(userLabel)
      make.right.equalTo(userLabel.snp.left).offset(-10)
    }
    
    userLabel.snp.makeConstraints { (make) in
      make.top.right.equalToSuperview()
      make.centerY.equalTo(labelLabel)
    }
    
    labelTableView.snp.makeConstraints { (make) in
      make.top.equalTo(labelLabel.snp.bottom)
      make.left.bottom.equalToSuperview()
      make.width.equalTo(assigneeTableView)
      make.right.equalTo(assigneeTableView.snp.left).offset(-10)
    }
    
    assigneeTableView.snp.makeConstraints { (make) in
      make.top.equalTo(userLabel.snp.bottom)
      make.right.bottom.equalToSuperview()
    }
  }
  
  func bindTableView() {
    viewModel.labelItems.asDriver()
      .drive(onNext: { [weak self] _ in self?.labelTableView.reloadData() })
      .disposed(by: bag)
    
    //datasource
    viewModel.labelItems.asObservable()
      .bind(to: labelTableView.rx.items) {
        [weak self] (tableView: UITableView, index: Int, element: LabelItem) in
        let cell = ListCell(style: .default, reuseIdentifier: ListCell.reuseIdentifier)
        cell.configureLabelCell(viewModel: (self?.viewModel)!, index: index)
        return cell
      }
      .disposed(by: bag)
    
    viewModel.assigneeItems.asDriver()
      .drive(onNext: { [weak self] _ in self?.assigneeTableView.reloadData() })
      .disposed(by: bag)
    
    //datasource
    viewModel.assigneeItems.asObservable()
      .bind(to: assigneeTableView.rx.items) {
        [weak self] (tableView: UITableView, index: Int, element: AssigneeItem) in
        let cell = ListCell(style: .default, reuseIdentifier: ListCell.reuseIdentifier)
        cell.configureAssigneeCell(viewModel: (self?.viewModel)!, index: index)
        return cell
      }
      .disposed(by: bag)
    
    //delegate
    labelTableView.rx
      .itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        let item = self?.viewModel.labelItems.value[indexPath.row]
        let items = self?.viewModel.labelItems.value
        self?.viewModel.labelItems.value = IssueService().checkLabel(label: item!.label, items: items!, check: nil)
      })
      .disposed(by: bag)
    
    //delegate
    assigneeTableView.rx
      .itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        let item = self?.viewModel.assigneeItems.value[indexPath.row]
        let items = self?.viewModel.assigneeItems.value
        self?.viewModel.assigneeItems.value = IssueService().checkUser(user: item!.user, items: items!, check: nil)
      })
      .disposed(by: bag)
    
  }
}
