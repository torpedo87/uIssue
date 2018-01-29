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
  
  private lazy var bodyTextView: CommentBox = {
    let issue = viewModel.selectedIssue
    let txtView = CommentBox(comment: nil, issue: issue, viewModel: viewModel)
    return txtView
  }()
  private lazy var closeButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("Close issue", for: UIControlState.normal)
    btn.backgroundColor = UIColor.red
    return btn
  }()
  
  private lazy var editButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("Edit", for: UIControlState.normal)
    btn.backgroundColor = UIColor.green
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
    setupView()
    bindUI()
  }
  
  func setupView() {
    title = "Issue Detail"
    view.backgroundColor = UIColor.white
    view.addSubview(titleTextField)
    view.addSubview(bodyTextView)
    view.addSubview(closeButton)
    
    titleTextField.snp.makeConstraints { (make) in
      make.top.equalToSuperview().offset(100)
      make.left.equalToSuperview().offset(50)
      make.right.equalToSuperview().offset(-50)
      make.height.equalTo(50)
    }
    
    bodyTextView.snp.makeConstraints { (make) in
      make.left.right.equalTo(titleTextField)
      make.top.equalTo(titleTextField.snp.bottom).offset(10)
    }
    
    closeButton.snp.makeConstraints { (make) in
      make.width.equalTo(150)
      make.height.equalTo(50)
      make.right.bottom.equalToSuperview().offset(-20)
    }
  }
  
  func bindUI() {
    
    closeButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<Bool> in
        return (self?.viewModel.editIssue(state: .closed, newTitleText: (self?.titleTextField.text!)!, newCommentText: (self?.bodyTextView.getText())!, label: [.enhancement]))!
      }
      .observeOn(MainScheduler.instance)
      .bind { [weak self] (success) in
        if success {
          self?.navigationController?.popViewController(animated: true)
        }
      }.disposed(by: bag)
    
    viewModel.issueDetail.asObservable()
      .map({ (issue) -> [Comment] in
        if let commentsDic = issue.commentsDic {
          return Array(commentsDic.values)
        }
        return []
      })
      .observeOn(MainScheduler.instance)
      .do(onNext: { [weak self] commentArr in
        var commentBoxArr = [CommentBox]()
        for i in 0...commentArr.count {
          var commentBox: CommentBox?
          if i != commentArr.count {
            commentBox = CommentBox(comment: commentArr[i], issue: nil, viewModel: (self?.viewModel)!)
          } else {
            let emptyComment = Comment(id: 1, user: (self?.viewModel.selectedIssue.repository?.owner)!, created_at: "", body: "")
            commentBox = CommentBox(comment: emptyComment, issue: nil, viewModel: (self?.viewModel)!)
            commentBox?.setEditMode()
          }
          self?.view.addSubview(commentBox!)
          commentBoxArr.append(commentBox!)
        }
        for i in 0..<commentBoxArr.count {
          if i == 0 {
            commentBoxArr[i].snp.makeConstraints({ (make) in
              make.top.equalTo((self?.bodyTextView.snp.bottom)!).offset(10)
              make.left.right.equalTo((self?.titleTextField)!)
            })
          } else {
            commentBoxArr[i].snp.makeConstraints({ (make) in
              make.top.equalTo(commentBoxArr[i-1].snp.bottom).offset(10)
              make.left.right.equalTo((self?.titleTextField)!)
            })
          }
        }
      })
      .subscribe()
      .disposed(by: bag)
  }
}
