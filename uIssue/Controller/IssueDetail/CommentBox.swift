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
  
  private lazy var cancelButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("CANCEL", for: UIControlState.normal)
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
    
    editButton.rx.controlEvent(UIControlEvents.touchUpInside)
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<Bool> in
        if self?.mode.value == .edit {
          if let issue = self?.issue {
            return (self?.viewModel.editIssue(state: .open, title: issue.title, comment: issue.body!, label: [.enhancement]))!
          } else {
            return (self?.viewModel.editComment())!
          }
        } else {
          return Observable.just(true)
        }
      }.bind(onNext: { [weak self] (success) in
        if success {
          if self?.mode.value == .normal {
            self?.mode.value = .edit
          } else {
            self?.mode.value = .normal
          }
        }
      })
      .disposed(by: bag)
    
    
    //edit or normal
    mode.asDriver()
      .do(onNext: { [weak self] modeValue in
        switch modeValue {
        case .edit: do {
          self?.commentTextView.isUserInteractionEnabled = true
          self?.commentTextView.backgroundColor = UIColor.yellow
          self?.editButton.setTitle("SAVE", for: UIControlState.normal)
          self?.cancelButton.isHidden = false
          }
        case .normal: do {
          self?.commentTextView.isUserInteractionEnabled = false
          self?.commentTextView.backgroundColor = UIColor.white
          self?.editButton.setTitle("EDIT", for: UIControlState.normal)
          self?.cancelButton.isHidden = true
          }
        }
      })
      .drive()
      .disposed(by: bag)
    
    
    //이슈 or 코멘트
    contents.asDriver()
      .do(onNext: { [weak self] body in
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
      .drive()
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
    topView.addSubview(editButton)
    topView.addSubview(cancelButton)
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
    
    cancelButton.snp.makeConstraints { (make) in
      cancelButton.sizeToFit()
      make.top.bottom.equalTo(topView)
      make.right.equalTo(editButton.snp.left).offset(-5)
    }
  }
  
  func getText() -> String {
    return commentTextView.text
  }
}
