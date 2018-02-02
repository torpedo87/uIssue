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
    txtField.layer.borderWidth = 1.0
    txtField.layer.borderColor = UIColor.black.cgColor
    txtField.text = viewModel.selectedIssue.title
    return txtField
  }()
  
  private lazy var bodyTextView: CommentBoxView = {
    let issue = viewModel.selectedIssue
    let commentBox = CommentBoxView(comment: nil, issue: issue, contentsMode: .issueBody, viewModel: viewModel)
    return commentBox
  }()
  
  private lazy var newCommentView: CommentBoxView = {
    let emptyComment = Comment(id: 1, user: (self.viewModel.selectedIssue.repository?.owner)!, created_at: "", body: "")
    let commentBox = CommentBoxView(comment: emptyComment, issue: nil, contentsMode: .newCommentBody, viewModel: viewModel)
    commentBox.setEditMode()
    return commentBox
  }()
  
  private lazy var closeButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("Close", for: UIControlState.normal)
    btn.backgroundColor = UIColor.red
    return btn
  }()
  
  private lazy var editButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("Edit", for: UIControlState.normal)
    btn.backgroundColor = UIColor.green
    return btn
  }()
  
  private lazy var tableView: UITableView = {
    let view = UITableView()
    view.register(CommentCell.self, forCellReuseIdentifier: CommentCell.reuseIdentifier)
    return view
  }()
  
  static func createWith(viewModel: IssueDetailViewViewModel) -> IssueDetailViewController {
    return {
      $0.viewModel = viewModel
      return $0
      }(IssueDetailViewController())
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewModel.requestFetchComments()
    setupView()
    bindUI()
    bindTableView()
  }
  
  func setupView() {
    title = "Issue Detail"
    view.backgroundColor = UIColor.white
    view.addSubview(titleTextField)
    view.addSubview(bodyTextView)
    view.addSubview(newCommentView)
    view.addSubview(tableView)
    view.addSubview(closeButton)
    
    titleTextField.snp.makeConstraints { (make) in
      make.top.equalToSuperview().offset(100)
      make.left.equalToSuperview().offset(80)
      make.right.equalToSuperview().offset(-80)
      make.height.equalTo(50)
    }
    
    bodyTextView.snp.makeConstraints { (make) in
      make.left.right.equalTo(titleTextField)
      make.top.equalTo(titleTextField.snp.bottom).offset(10)
    }
    
    tableView.snp.makeConstraints { (make) in
      make.top.equalTo(bodyTextView.snp.bottom).offset(10)
      make.left.right.equalToSuperview()
      make.bottom.equalTo(newCommentView.snp.top).offset(-10)
    }
    
    newCommentView.snp.makeConstraints { (make) in
      make.left.right.equalTo(titleTextField)
      make.bottom.equalTo(view).offset(-50)
    }
    
    closeButton.snp.makeConstraints { (make) in
      closeButton.sizeToFit()
      make.centerY.equalTo(titleTextField)
      make.left.equalTo(titleTextField.snp.right)
      make.right.equalToSuperview()
    }
  }
  
  func bindUI() {
    
    closeButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<Bool> in
        return (self?.viewModel.editIssue(state: .closed, newTitleText: (self?.titleTextField.text!)!, newBodyText: (self?.bodyTextView.getText())!, label: [.enhancement]))!
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
