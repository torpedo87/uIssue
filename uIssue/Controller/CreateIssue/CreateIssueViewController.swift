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
    table.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
    table.rowHeight = 50
    table.allowsMultipleSelection = true
    return table
  }()
  
  private lazy var assigneeTableView: UITableView = {
    let table = UITableView()
    table.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
    table.rowHeight = 50
    table.allowsMultipleSelection = true
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
    view.addSubview(labelLabel)
    view.addSubview(userLabel)
    view.addSubview(labelTableView)
    view.addSubview(assigneeTableView)
    
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
    
    labelLabel.snp.makeConstraints { (make) in
      make.top.equalTo(submitButton.snp.bottom).offset(10)
      make.left.equalTo(titleTextField)
      make.height.equalTo(50)
      make.width.equalTo(userLabel)
      make.right.equalTo(userLabel.snp.left).offset(-10)
    }
    
    userLabel.snp.makeConstraints { (make) in
      make.top.equalTo(submitButton.snp.bottom).offset(10)
      make.right.equalTo(titleTextField)
      make.centerY.equalTo(labelLabel)
    }
    
    labelTableView.snp.makeConstraints { (make) in
      make.top.equalTo(labelLabel.snp.bottom)
      make.left.equalTo(titleTextField)
      make.bottom.equalToSuperview().offset(-50)
      make.width.equalTo(assigneeTableView)
      make.right.equalTo(assigneeTableView.snp.left).offset(-10)
    }
    
    assigneeTableView.snp.makeConstraints { (make) in
      make.top.equalTo(userLabel.snp.bottom)
      make.right.equalTo(titleTextField)
      make.bottom.equalToSuperview().offset(-50)
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
        let labels = Array((self?.viewModel)!.labelDict.values)
        let users = Array((self?.viewModel)!.userDict.values)
        print("labels -----", labels)
        print("users -----", users)
        return (self?.viewModel.createIssue(title: (self?.titleTextField.text)!, newComment: (self?.commetTextView.text)!, label: labels, users: users))!
      }
      .debug()
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
    
  }
  
  func bindTableView() {
    viewModel.labels.asDriver()
      .drive(onNext: { [weak self] _ in self?.labelTableView.reloadData() })
      .disposed(by: bag)
    
    //datasource
    viewModel.labels.asObservable()
      .bind(to: labelTableView.rx.items) {
        (tableView: UITableView, index: Int, element: IssueService.Label) in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") else { return UITableViewCell() }
        cell.textLabel?.text = element.rawValue
        return cell
      }
      .disposed(by: bag)
    
    viewModel.assignees.asDriver()
      .drive(onNext: { [weak self] _ in self?.assigneeTableView.reloadData() })
      .disposed(by: bag)
    
    //datasource
    viewModel.assignees.asObservable()
      .bind(to: assigneeTableView.rx.items) {
        (tableView: UITableView, index: Int, element: User) in
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") else { return UITableViewCell() }
        cell.textLabel?.text = element.login
        return cell
      }
      .disposed(by: bag)
    
    //delegate
    labelTableView.rx
      .itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        let cell = self?.labelTableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        let label = self?.viewModel.labels.value[indexPath.row]
        self?.viewModel.labelDict[indexPath.row] = label
      })
      .disposed(by: bag)
    
    labelTableView.rx
      .itemDeselected
      .subscribe(onNext: { [weak self] indexPath in
        let cell = self?.labelTableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
        self?.viewModel.labelDict.removeValue(forKey: indexPath.row)
      })
      .disposed(by: bag)
    
    //delegate
    assigneeTableView.rx
      .itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        let cell = self?.assigneeTableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        let user = self?.viewModel.assignees.value[indexPath.row]
        self?.viewModel.userDict[indexPath.row] = user
      })
      .disposed(by: bag)
    
    assigneeTableView.rx
      .itemDeselected
      .subscribe(onNext: { [weak self] indexPath in
        let cell = self?.assigneeTableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
        self?.viewModel.userDict.removeValue(forKey: indexPath.row)
      })
      .disposed(by: bag)
  }
  
}
