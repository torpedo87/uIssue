//
//  IssueDetailViewController.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 23..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class IssueDetailViewController: UIViewController {
  private var viewModel: IssueDetailViewViewModel!
  private let bag = DisposeBag()
  
  private lazy var titleTextField: UITextField = {
    let txtField = UITextField()
    txtField.text = viewModel.issueDetail.value.title
    txtField.font = UIFont.systemFont(ofSize: 25)
    return txtField
  }()
  
  private lazy var bodyTextView: CommentBoxView = {
    let issue = viewModel.issueDetail.value
    let commentBox = CommentBoxView(comment: nil, issue: issue, contentsMode: .issueBody, viewModel: viewModel)
    return commentBox
  }()
  
  private lazy var newCommentView: CommentBoxView = {
    let emptyComment = Comment(id: 1, user: Me.shared.getUser()!, created_at: "", body: "")
    let commentBox = CommentBoxView(comment: emptyComment, issue: nil, contentsMode: .newCommentBody, viewModel: viewModel)
    commentBox.setEditMode()
    return commentBox
  }()

  private lazy var tableView: UITableView = {
    let view = UITableView()
    view.register(CommentCell.self, forCellReuseIdentifier: CommentCell.reuseIdentifier)
    return view
  }()
  
  private lazy var closeButton: UIButton = {
    let btn = UIButton()
    btn.backgroundColor = UIColor(hex: "3CC75A")
    return btn
  }()
  
  static func createWith(viewModel: IssueDetailViewViewModel) -> IssueDetailViewController {
    return {
      $0.viewModel = viewModel
      return $0
      }(IssueDetailViewController())
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if viewModel.issueDetail.value.isCommentsFetched == nil {
      viewModel.requestFetchComments()
    }
    
    setupView()
    bindUI()
    bindTableView()
  }
  
  func setupView() {
    title = "Issue Detail"
    view.backgroundColor = UIColor.white
    view.addSubview(closeButton)
    view.addSubview(titleTextField)
    view.addSubview(bodyTextView)
    view.addSubview(newCommentView)
    view.addSubview(tableView)
    
    titleTextField.snp.makeConstraints { (make) in
      make.top.equalToSuperview().offset(85)
      make.left.right.equalToSuperview()
      make.height.equalTo(100)
    }
    
    bodyTextView.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.top.equalTo(titleTextField.snp.bottom)
    }
    
    tableView.snp.makeConstraints { (make) in
      make.top.equalTo(bodyTextView.snp.bottom)
      make.left.right.equalToSuperview()
      make.bottom.equalTo(newCommentView.snp.top).offset(-10)
    }
    
    newCommentView.snp.makeConstraints { (make) in
      make.left.right.equalTo(titleTextField)
      make.bottom.equalTo(closeButton.snp.top).offset(-10)
    }
    
    closeButton.snp.makeConstraints { (make) in
      closeButton.sizeToFit()
      make.right.equalTo(titleTextField)
      make.bottom.equalTo(view).offset(-50)
    }
  }
  
  func bindUI() {
    
    viewModel.issueDetail.asDriver()
      .drive(onNext: { [weak self] issue in
        if issue.state == "closed" {
          self?.closeButton.setTitle("REOPEN ISSUE", for: UIControlState.normal)
        } else {
          self?.closeButton.setTitle("CLOSE ISSUE", for: UIControlState.normal)
        }
      }).disposed(by: bag)
    
    closeButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<Bool> in
        if let issue = self?.viewModel.issueDetail.value {
          let labels = IssueService().transformIssueLabelToLabel(issueLabelArr: issue.labels)
          if issue.state == "closed" {
            return (self?.viewModel.editIssue(state: .open, newTitleText: issue.title, newBodyText: issue.body!, label: labels))!
          } else {
            return (self?.viewModel.editIssue(state: .closed, newTitleText: issue.title, newBodyText: issue.body!, label: labels))!
          }
        }
        return Observable.just(false)
      }
      .observeOn(MainScheduler.instance)
      .bind { [weak self] (success) in
        if success {
          self?.navigationController?.popViewController(animated: true)
        }
      }.disposed(by: bag)
    
  }
  
  func bindTableView() {
    viewModel.commentList.asDriver()
      .drive(onNext: { [weak self] _ in self?.tableView.reloadData() })
      .disposed(by: bag)
    
    //datasource
    viewModel.commentList.asObservable()
      .observeOn(MainScheduler.instance)
      .bind(to: tableView.rx.items) {
        [weak self] (tableView: UITableView, index: Int, element: Comment) in
        let cell = CommentCell(comment: element, viewModel: (self?.viewModel)!)
        return cell
      }
      .disposed(by: bag)
    
  }
}
