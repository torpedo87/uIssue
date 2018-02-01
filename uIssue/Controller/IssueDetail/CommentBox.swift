//
//  CommentBox.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 26..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CommentBox: UIView {
  
  enum Mode {
    case normal
    case edit
  }
  
  enum Contents {
    case issueBody
    case commentBody
  }
  
  private var viewModel: IssueDetailViewViewModel!
  private let bag = DisposeBag()
  private var comment: Comment?
  private var issue: Issue?
  
  private var mode = Variable<Mode>(.normal)
  
  private var contents: Driver<Contents> {
    return Observable.create { [weak self] observer in
      if let _ = self?.comment {
        observer.onNext(.commentBody)
      }
      if let _ = self?.issue {
        observer.onNext(.issueBody)
      }
      return Disposables.create()
      }.asDriver(onErrorJustReturn: .commentBody)
  }
  
  private lazy var topView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.lightGray
    return view
  }()
  
  private lazy var userLabel: UILabel = {
    let label = UILabel()
    return label
  }()
  
  private lazy var editButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("EDIT", for: UIControlState.normal)
    btn.backgroundColor = UIColor.red
    return btn
  }()
  
  private lazy var saveButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("SAVE", for: UIControlState.normal)
    btn.backgroundColor = UIColor.red
    return btn
  }()
  
  private lazy var cancelButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("CANCEL", for: UIControlState.normal)
    btn.backgroundColor = UIColor.red
    return btn
  }()
  
  private lazy var deleteButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("DELETE", for: UIControlState.normal)
    btn.backgroundColor = UIColor.red
    return btn
  }()
  
  private lazy var commentTextView: UITextView = {
    let view = UITextView()
    view.isScrollEnabled = false
    return view
  }()
  
  init(comment: Comment?, issue: Issue?, viewModel: IssueDetailViewViewModel) {
    self.viewModel = viewModel
    self.issue = issue
    self.comment = comment
    super.init(frame: CGRect.zero)
    setupView()
    bindUI()
  }
  
  func bindUI() {
    
    commentTextView.rx.text.orEmpty.asDriver()
      .drive(onNext: { [weak self] text in
        if text.isEmpty {
          self?.cancelButton.isEnabled = false
          self?.saveButton.isEnabled = false
        } else {
          self?.cancelButton.isEnabled = true
          self?.saveButton.isEnabled = true
        }
      })
      .disposed(by: bag)
    
    
    cancelButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        if let _ = self?.issue {
          self?.viewModel.cancelEditIssue()
        } else {
          self?.viewModel.cancelEditComment(newComment: (self?.comment)!)
        }
        self?.mode.value = .normal
      })
      .disposed(by: bag)
    
    deleteButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<Bool> in
        if let comment = self?.comment {
          return (self?.viewModel.deleteComment(issue: (self?.viewModel.selectedIssue)!, existingComment: comment, repoIndex: (self?.viewModel.repoIndex)!))!
        } else {
          return Observable.just(false)
        }
    }.asDriver(onErrorJustReturn: false)
    .drive()
    .disposed(by: bag)
    
    editButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        self?.mode.value = .edit
      })
      .disposed(by: bag)
    
    
    saveButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<Bool> in
        if let issue = self?.issue {
          return (self?.viewModel.editIssue(state: .open, newTitleText: issue.title, newCommentText: (self?.commentTextView.text)!, label: [.enhancement]))!
        } else {
          if self?.comment?.body != "" {
            return (self?.viewModel.editComment(issue: (self?.viewModel.selectedIssue)!, existingComment: (self?.comment)!, repoIndex: (self?.viewModel.repoIndex)!, newCommentText: (self?.commentTextView.text)!))!
          } else {
            return (self?.viewModel.createComment(issue: (self?.viewModel.selectedIssue)!, newCommentBody: (self?.commentTextView.text)!, repoIndex: (self?.viewModel.repoIndex)!))!
          }
        }
      }.catchErrorJustReturn(false)
      .bind(onNext: { [weak self] (success) in
        if success {
          self?.mode.value = .normal
        }
      })
      .disposed(by: bag)
    
    
    //edit or normal
    mode.asDriver()
      .drive(onNext: { [weak self] modeValue in
        switch modeValue {
        case .edit: do {
          self?.commentTextView.isUserInteractionEnabled = true
          self?.commentTextView.backgroundColor = UIColor.yellow
          self?.editButton.isHidden = true
          self?.deleteButton.isHidden = true
          self?.saveButton.isHidden = false
          self?.cancelButton.isHidden = false
          }
        case .normal: do {
          self?.commentTextView.isUserInteractionEnabled = false
          self?.commentTextView.backgroundColor = UIColor.white
          self?.editButton.isHidden = false
          self?.deleteButton.isHidden = false
          self?.saveButton.isHidden = true
          self?.cancelButton.isHidden = true
          }
        }
      })
      .disposed(by: bag)
    
    
    //이슈 or 코멘트
    contents.asDriver()
      .drive(onNext: { [weak self] body in
        switch body {
        case .commentBody: do {
          self?.userLabel.text = self?.comment!.user.login
          self?.commentTextView.text = self?.comment!.body
          }
        case .issueBody: do {
          self?.userLabel.text = self?.issue!.user.login
          self?.commentTextView.text = self?.issue!.body
          self?.topView.backgroundColor = UIColor.darkGray
          }
        }
      })
      .disposed(by: bag)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupView() {
    layer.borderWidth = 1.0
    layer.borderColor = UIColor.black.cgColor
    addSubview(topView)
    topView.addSubview(userLabel)
    topView.addSubview(saveButton)
    topView.addSubview(editButton)
    topView.addSubview(cancelButton)
    topView.addSubview(deleteButton)
    addSubview(commentTextView)
    
    topView.snp.makeConstraints { (make) in
      make.left.top.right.equalToSuperview()
      make.height.equalTo(50)
    }
    
    commentTextView.snp.makeConstraints { (make) in
      make.left.bottom.right.equalToSuperview()
      make.top.equalTo(topView.snp.bottom)
    }
    
    userLabel.snp.makeConstraints { (make) in
      userLabel.sizeToFit()
      make.left.top.bottom.equalTo(topView)
    }
    
    editButton.snp.makeConstraints { (make) in
      editButton.sizeToFit()
      make.right.top.bottom.equalTo(topView)
    }
    
    saveButton.snp.makeConstraints { (make) in
      saveButton.sizeToFit()
      make.edges.equalTo(editButton)
    }
    
    cancelButton.snp.makeConstraints { (make) in
      cancelButton.sizeToFit()
      make.top.bottom.equalTo(topView)
      make.right.equalTo(editButton.snp.left).offset(-5)
    }
    
    deleteButton.snp.makeConstraints { (make) in
      deleteButton.sizeToFit()
      make.edges.equalTo(cancelButton)
    }
  }
  
  func getText() -> String {
    return commentTextView.text
  }
  
  func setEditMode() {
    mode.value = .edit
  }
}
