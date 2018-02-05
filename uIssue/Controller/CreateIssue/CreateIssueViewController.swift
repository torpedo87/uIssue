//
//  CreateIssueViewController.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 23..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class CreateIssueViewController: UIViewController {
  
  private var viewModel: CreateIssueViewViewModel!
  private let bag = DisposeBag()
  private lazy var titleTextField: UITextField = {
    let view = UITextField()
    view.placeholder = "Leave a new issue"
    view.layer.borderWidth = 1.0
    view.layer.borderColor = UIColor.black.cgColor
    return view
  }()
  
  private lazy var commetTextView: UITextView = {
    let view = UITextView()
    view.layer.borderWidth = 1.0
    view.layer.borderColor = UIColor.black.cgColor
    return view
  }()
  
  private lazy var cancelButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("CANCEL", for: UIControlState.normal)
    btn.backgroundColor = UIColor(hex: "3CC75A")
    return btn
  }()
  
  private lazy var submitButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("Submit new issue", for: UIControlState.normal)
    btn.setTitle("Enter title", for: UIControlState.disabled)
    btn.backgroundColor = UIColor(hex: "3CC75A")
    btn.isEnabled = false
    return btn
  }()
  
  private lazy var labelButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("Label", for: UIControlState.normal)
    btn.backgroundColor = UIColor(hex: "3CC75A")
    return btn
  }()
  
  private lazy var propertyTableView: UITableView = {
    let table = UITableView()
    table.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
    table.rowHeight = 50
    return table
  }()
  
  static func createWith(viewModel: CreateIssueViewViewModel) -> CreateIssueViewController {
    return {
      $0.viewModel = viewModel
      return $0
      }(CreateIssueViewController())
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    bindUI()
    bindTableView()
  }
  
  func setupView() {
    title = "Create Issue"
    view.backgroundColor = UIColor.white
    view.addSubview(titleTextField)
    view.addSubview(commetTextView)
    view.addSubview(submitButton)
    view.addSubview(cancelButton)
    view.addSubview(propertyTableView)
    view.addSubview(labelButton)
    
    titleTextField.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.height.equalTo(50)
      make.left.equalToSuperview().offset(50)
      make.right.equalToSuperview().offset(-50)
      make.top.equalToSuperview().offset(100)
    }
    
    commetTextView.snp.makeConstraints { (make) in
      make.centerX.left.right.equalTo(titleTextField)
      make.height.equalTo(200)
      make.top.equalTo(titleTextField.snp.bottom).offset(10)
    }
    
    cancelButton.snp.makeConstraints { (make) in
      make.left.equalTo(commetTextView)
      make.height.width.centerY.equalTo(submitButton)
      make.right.equalTo(submitButton.snp.left).offset(-10)
    }
    
    submitButton.snp.makeConstraints { (make) in
      make.right.equalTo(commetTextView)
      make.height.equalTo(50)
      make.top.equalTo(commetTextView.snp.bottom).offset(10)
    }
    
    propertyTableView.snp.makeConstraints { (make) in
      make.top.equalTo(submitButton.snp.bottom).offset(10)
      make.left.right.equalTo(titleTextField)
      make.bottom.equalToSuperview().offset(-50)
    }
    
    labelButton.snp.makeConstraints { (make) in
      make.width.height.equalTo(50)
      make.left.bottom.equalToSuperview()
    }
  }
  
  func bindUI() {
    //사용자 입력값을 뷰모델에 전달
    titleTextField.rx.text.orEmpty
      .bind(to: viewModel.titleInput)
      .disposed(by: bag)
    
    //뷰모델에서 가공된 결과를 받아서 바인딩
    viewModel.validate
      .drive(submitButton.rx.isEnabled)
      .disposed(by: bag)
    
    
    submitButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<Bool> in
        (self?.viewModel.createIssue(title: (self?.titleTextField.text)!, newComment: (self?.commetTextView.text)!, label: [.bug]))!
      }
      .observeOn(MainScheduler.instance)
      .bind { [weak self] (success) in
        if success {
          self?.dismiss(animated: true, completion: nil)
        }
      }.disposed(by: bag)
    
    cancelButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        self?.dismiss(animated: true, completion: nil)
      })
      .disposed(by: bag)
    
    labelButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        //self?.viewModel.addLabel(newLabel: .bug)
      })
      .disposed(by: bag)
  }
  
  func bindTableView() {
    
    let sections: [MultipleSectionModel] = [
      .LabelSection(title: "Labels", items: transformLabelsToItem(labels: IssueService.Label.arr)),
      .AssigneeSection(title: "Assignees", items: transformUsersToItem(users: viewModel.assignees.value))
    ]
    
    let dataSource = CreateIssueViewController.dataSource()
    
    Observable.just(sections)
      .bind(to: propertyTableView.rx.items(dataSource: dataSource))
      .disposed(by: bag)
  }
  
  func transformLabelsToItem(labels: [IssueService.Label]) -> [SectionItem] {
    var tempArr = [SectionItem]()
    for label in labels {
      let item = SectionItem.LabelSectionItem(label: label)
      tempArr.append(item)
    }
    return tempArr
  }
  
  func transformUsersToItem(users: [User]) -> [SectionItem] {
    var tempArr = [SectionItem]()
    for user in users {
      let item = SectionItem.AssigneeSectionItem(user: user)
      tempArr.append(item)
    }
    return tempArr
  }
}

extension CreateIssueViewController {
  static func dataSource() -> RxTableViewSectionedReloadDataSource<MultipleSectionModel> {
    return RxTableViewSectionedReloadDataSource<MultipleSectionModel>(
      configureCell: { (dataSource, table, idxPath, _) in
        switch dataSource[idxPath] {
        case let .LabelSectionItem(label):
          let cell: UITableViewCell = table.dequeueReusableCell(withIdentifier: "TableViewCell", for: idxPath)
          cell.textLabel?.text = label.rawValue
          
          return cell
        case let .AssigneeSectionItem(user):
          let cell: UITableViewCell = table.dequeueReusableCell(withIdentifier: "TableViewCell", for: idxPath)
          cell.textLabel?.text = user.login
          
          return cell
        
        }
    },
      titleForHeaderInSection: { dataSource, index in
        let section = dataSource[index]
        return section.title
    }
    )
  }
}
