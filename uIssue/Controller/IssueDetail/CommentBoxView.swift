//
//  CommentBoxView.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 26..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CommentBoxView: UIView {
  
  enum Mode {
    case normal
    case edit
  }
  
  enum Contents {
    case issueBody
    case commentBody
    case newCommentBody
  }
  
  private var viewModel: IssueDetailViewViewModel!
  private let bag = DisposeBag()
  private var comment: Comment?
  private var issue: Issue?
  
  private var mode = Variable<Mode>(.normal)
  
  private var contentsMode: Contents!
  
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
  
  init(comment: Comment?, issue: Issue?, contentsMode: Contents, viewModel: IssueDetailViewViewModel) {
    self.contentsMode = contentsMode
    self.viewModel = viewModel
    self.issue = issue
    self.comment = comment
    super.init(frame: CGRect.zero)
    setupView()
    bindUI()
  }
  
  func bindUI() {
    
    commentTextView.rx.text.orEmpty.asDriver()
      .map({ (text) -> Bool in
        return !text.isEmpty
      })
      .drive(cancelButton.rx.isEnabled)
      .disposed(by: bag)
      
    commentTextView.rx.text.orEmpty.asDriver()
      .map({ (text) -> Bool in
        return !text.isEmpty
      })
      .drive(saveButton.rx.isEnabled)
      .disposed(by: bag)
    
    cancelButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        switch (self?.contentsMode)! {
        case .issueBody: do {
          self?.commentTextView.text = self?.issue?.body
          }
        case .commentBody: do {
          self?.commentTextView.text = self?.comment?.body
          }
        case .newCommentBody: do {
          self?.commentTextView.text = ""
          }
        }
        self?.mode.value = .normal
      })
      .disposed(by: bag)
    
    deleteButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<Bool> in
        switch (self?.contentsMode)! {
        case .issueBody: do {
          return (self?.viewModel.editIssue(state: IssueService.State.open, newTitleText: (self?.issue?.title)!, newBodyText: "", label: [.enhancement]))!
          }
        case .commentBody: do {
          return (self?.viewModel.deleteComment(existingComment: (self?.comment)!))!
          }
        case .newCommentBody: do {
          return Observable.just(false)
          }
        }
    }.asDriver(onErrorJustReturn: false)
      .drive(onNext: { [weak self] bool in
        if bool {
          switch (self?.contentsMode)! {
          case .issueBody: do {
            self?.commentTextView.text = ""
            }
          case .newCommentBody: do {
            self?.commentTextView.text = ""
            }
          default: break
          }
        }
      })
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
        switch (self?.contentsMode)! {
        case .issueBody: do {
          return (self?.viewModel.editIssue(state: .open, newTitleText: (self?.issue)!.title, newBodyText: (self?.commentTextView.text)!, label: [.enhancement]))!
          }
        case .commentBody: do {
          return (self?.viewModel.editComment(existingComment: (self?.comment)!, newCommentText: (self?.commentTextView.text)!))!
          }
        case .newCommentBody: do {
          return (self?.viewModel.createComment(newCommentBody: (self?.commentTextView.text)!))!
          }
        }
      }.asDriver(onErrorJustReturn: false)
      .drive(onNext: { [weak self] (success) in
        if success {
          switch (self?.contentsMode)! {
          case .newCommentBody: do {
            self?.commentTextView.text = ""
            }
          default: do {
            self?.mode.value = .normal
            }
          }
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
    
    
    switch contentsMode! {
    case .commentBody: do {
      self.userLabel.text = self.comment!.user.login
      self.commentTextView.text = self.comment!.body
      }
    case .issueBody: do {
      self.userLabel.text = self.issue!.user.login
      self.commentTextView.text = self.issue!.body
      self.topView.backgroundColor = UIColor.darkGray
      }
    case .newCommentBody: do {
      self.userLabel.text = "New Comment"
      self.commentTextView.text = ""
      }
    }
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
  
  func setEmpty() {
    issue = nil
    comment = nil
    userLabel.text = nil
    commentTextView.text = nil
  }
  
}
