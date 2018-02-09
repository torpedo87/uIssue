//
//  IssuePropertyView.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 6..
//  Copyright © 2018년 samchon. All rights reserved.0.
//

import UIKit
import RxSwift
import RxCocoa

protocol PropertySettable {
  var labelItemsDict: BehaviorRelay<[String:LabelItem]> { get }
  var assigneeItemsDict: BehaviorRelay<[String:AssigneeItem]> { get }
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
      make.right.equalTo(userLabel.snp.left)
    }
    
    userLabel.snp.makeConstraints { (make) in
      make.top.right.equalToSuperview()
      make.width.height.equalTo(labelLabel)
    }
    
    labelTableView.snp.makeConstraints { (make) in
      make.height.equalTo(Int(labelTableView.rowHeight) * IssueService.Label.arr.count)
      make.top.equalTo(labelLabel.snp.bottom)
      make.left.equalToSuperview()
      make.width.equalTo(assigneeTableView)
      make.right.equalTo(assigneeTableView.snp.left)
    }
    
    assigneeTableView.snp.makeConstraints { (make) in
      make.top.equalTo(userLabel.snp.bottom)
      make.right.equalToSuperview()
      make.height.equalTo(labelTableView)
    }
  }
  
  func bindTableView() {
    viewModel.labelItemsDict.asDriver()
      .drive(onNext: { [weak self] _ in
        self?.labelTableView.reloadData()
      })
      .disposed(by: bag)
    viewModel.assigneeItemsDict.asDriver()
      .drive(onNext: { [weak self] _ in
        self?.assigneeTableView.reloadData()
      })
      .disposed(by: bag)
    
    
    //datasource
    viewModel.labelItemsDict.asObservable()
      .map({ (dict) -> [LabelItem] in
        return Array(dict.values)
      })
      .bind(to: labelTableView.rx.items) {
        (tableView: UITableView, index: Int, element: LabelItem) in
        let cell = ListCell(style: .default, reuseIdentifier: ListCell.reuseIdentifier)
        cell.configureLabelCell(item: element)
        return cell
      }
      .disposed(by: bag)
    viewModel.assigneeItemsDict.asObservable()
      .map({ (dict) -> [AssigneeItem] in
        return Array(dict.values)
      })
      .bind(to: assigneeTableView.rx.items) {
        (tableView: UITableView, index: Int, element: AssigneeItem) in
        let cell = ListCell(style: .default, reuseIdentifier: ListCell.reuseIdentifier)
        cell.configureAssigneeCell(item: element)
        return cell
      }
      .disposed(by: bag)
    
    //delegate
    labelTableView.rx
      .modelSelected(LabelItem.self)
      .observeOn(MainScheduler.instance)
      .flatMap({ [weak self] model -> Observable<Bool> in
        if let viewmodel = self?.viewModel as? IssueDetailViewViewModel {
          let issue = viewmodel.issueDetail.value
          var checkedDict =
            self?.viewModel.labelItemsDict.value.filter{ $0.value.isChecked }
          
          if model.isChecked {
            checkedDict?.removeValue(forKey: model.label.rawValue)
          } else {
            checkedDict![model.label.rawValue] = model
          }
          
          let updatedLabels = Array(checkedDict!.values).map{ $0.label }
          let state = IssueService().transformStrToState(stateString: issue.state)
          
          return viewmodel.editIssue(state: state!,
                                     newTitleText: issue.title,
                                     newBodyText: issue.body!,
                                     label: updatedLabels,
                                     assignees: issue.assignees)
        } else {
          let updatedDict
            = IssuePropertyItemService().updateLabelWhenToggled(
              dict: (self?.viewModel.labelItemsDict.value)!,
              item: model)
          self?.viewModel.labelItemsDict.accept(updatedDict)
          return Observable.just(false)
        }
      })
      .subscribe()
      .disposed(by: bag)
      
    
    //delegate
    assigneeTableView.rx
      .modelSelected(AssigneeItem.self)
      .observeOn(MainScheduler.instance)
      .flatMap({ [weak self] model -> Observable<Bool> in
        if let viewmodel = self?.viewModel as? IssueDetailViewViewModel {
          let issue = viewmodel.issueDetail.value
          var checkedDict =
            self?.viewModel.assigneeItemsDict.value.filter{ $0.value.isChecked }
          
          if model.isChecked {
            checkedDict?.removeValue(forKey: model.user.login)
          } else {
            checkedDict![model.user.login] = model
          }
          
          let updatedUsers = Array(checkedDict!.values).map{ $0.user }
          let labels =
            IssueService().transformIssueLabelToLabel(issueLabelArr: issue.labels)
          let state = IssueService().transformStrToState(stateString: issue.state)
          return viewmodel.editIssue(state: state!,
                                     newTitleText: issue.title,
                                     newBodyText: issue.body!,
                                     label: labels,
                                     assignees: updatedUsers)
        } else {
          let updatedDict =
            IssuePropertyItemService().updateAssigneeWhenToggled(
              dict: (self?.viewModel.assigneeItemsDict.value)!,
              item: model)
          self?.viewModel.assigneeItemsDict.accept(updatedDict)
          return Observable.just(false)
        }
      })
      .subscribe()
      .disposed(by: bag)
    
  }
}
