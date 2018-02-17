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
import Kingfisher

class CommentBoxView: UIView {
  
  enum Mode {
    case normal
    case edit
  }
  
  enum Contents {
    case issueTitle
    case issueBody
    case commentBody
    case newCommentBody
  }
  
  private var viewModel: IssueDetailViewViewModel!
  private let bag = DisposeBag()
  private var comment: Comment?
  private var issue: Issue?
  private var mode = BehaviorRelay<Mode>(value: .normal)
  private var contentsMode: Contents!
  
  private let topView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(hex: "F1F8FF")
    return view
  }()
  
  private let avatarImageView: UIImageView = {
    let view = UIImageView()
    view.contentMode = .scaleAspectFit
    return view
  }()
  
  private let userLabel: UILabel = {
    let label = UILabel()
    return label
  }()
  
  private let editButton: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "edit"), for: UIControlState.normal)
    return btn
  }()
  
  private let saveButton: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "save"), for: UIControlState.normal)
    return btn
  }()
  
  private let cancelButton: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "cancel"), for: UIControlState.normal)
    return btn
  }()
  
  private let deleteButton: UIButton = {
    let btn = UIButton()
    btn.setImage(UIImage(named: "delete"), for: UIControlState.normal)
    return btn
  }()
  
  private let commentTextView: UITextView = {
    let view = UITextView()
    view.isScrollEnabled = false
    return view
  }()
  
  init(comment: Comment?, issue: Issue?, contentsMode: Contents,
       viewModel: IssueDetailViewViewModel) {
    self.contentsMode = contentsMode
    self.viewModel = viewModel
    self.issue = issue
    self.comment = comment
    super.init(frame: CGRect.zero)
    setupView()
    bindUI()
  }
  
  func bindUI() {
    //텍스트에 따라 버튼 활성화
    commentTextView.rx.text.orEmpty.asDriver()
      .map({ (text) -> Bool in
        return !text.isEmpty
      })
      .drive(saveButton.rx.isEnabled)
      .disposed(by: bag)
    
    //취소버튼 탭
    cancelButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        switch (self?.contentsMode)! {
        case .issueBody: do {
          self?.commentTextView.text = self?.viewModel.issueDetail.value.body
          }
        case .commentBody: do {
          self?.commentTextView.text = self?.comment?.body
          }
        case .newCommentBody: do {
          self?.commentTextView.text = ""
          }
        case .issueTitle:
          self?.commentTextView.text = self?.issue?.title
        }
        self?.mode.accept(.normal)
      })
      .disposed(by: bag)
    
    //삭제버튼 탭시 삭제 요청하기
    deleteButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<Bool> in
        if let issue = self?.viewModel.issueDetail.value {
          let issueState =
            IssueService().transformStrToState(stateString: issue.state)
          let issueLabel =
            IssueService().transformIssueLabelToLabel(issueLabelArr: issue.labels)
          switch (self?.contentsMode)! {
          case .issueBody: do {
            return (self?.viewModel.editIssue(state: issueState!,
                                              newTitleText: issue.title,
                                              newBodyText: "",
                                              label: issueLabel,
                                              assignees: issue.assignees))!
            }
          case .commentBody: do {
            return (self?.viewModel.deleteComment(existingComment: (self?.comment)!))!
            }
          default: do {
            return Observable.just(false)
            }
          }
        } else {
          return Observable.just(false)
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
    
    //편집버튼 탭
    editButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        self?.mode.accept(.edit)
      })
      .disposed(by: bag)
    
    //저장버튼 탭
    saveButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<Bool> in
        
        let assignees = self?.viewModel.issueDetail.value.assignees
        let issueLabels = self?.viewModel.issueDetail.value.labels
        let labels =
          IssueService().transformIssueLabelToLabel(issueLabelArr: issueLabels!)
        switch (self?.contentsMode)! {
        case .issueBody: do {
          
          return (self?.viewModel.editIssue(state: .open,
                                            newTitleText: (self?.issue)!.title,
                                            newBodyText: (self?.commentTextView.text)!,
                                            label: labels,
                                            assignees: assignees!))!
          }
        case .commentBody: do {
          return (self?.viewModel.editComment(existingComment: (self?.comment)!,
                                              newCommentText: (self?.commentTextView.text)!))!
          }
        case .newCommentBody: do {
          return (self?.viewModel.createComment(newCommentBody: (self?.commentTextView.text)!))!
          }
        case .issueTitle:
          return (self?.viewModel.editIssue(state: .open,
                                            newTitleText: (self?.commentTextView.text)!,
                                            newBodyText: (self?.issue)!.body!,
                                            label: labels,
                                            assignees: assignees!))!
        }
      }.asDriver(onErrorJustReturn: false)
      .drive(onNext: { [weak self] (success) in
        if success {
          switch (self?.contentsMode)! {
          case .newCommentBody: do {
            self?.commentTextView.text = ""
            }
          default: do {
            self?.mode.accept(.normal)
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
          self?.commentTextView.backgroundColor = UIColor(hex: "FCFCA8")
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
      let imgUrl = URL(string: self.comment!.user.avatar_url)
      self.avatarImageView.kf.setImage(with: imgUrl)
      self.userLabel.text = self.comment!.user.login
      self.commentTextView.text = self.comment!.body
      }
    case .issueBody: do {
      let imgUrl = URL(string: self.issue!.user.avatar_url)
      self.avatarImageView.kf.setImage(with: imgUrl)
      self.userLabel.text = self.issue!.user.login
      self.commentTextView.text = self.issue!.body
      }
    case .newCommentBody: do {
      let me = Me.shared.getUser()
      let imgUrl = URL(string: me!.avatar_url)
      self.avatarImageView.kf.setImage(with: imgUrl)
      self.userLabel.text = me!.login
      self.commentTextView.text = ""
      }
    case .issueTitle: do {
      let me = Me.shared.getUser()
      let imgUrl = URL(string: me!.avatar_url)
      self.avatarImageView.kf.setImage(with: imgUrl)
      self.userLabel.text = me!.login
      self.commentTextView.text = self.issue!.title
      }
    }
  }
  
  func getText() -> String {
    return commentTextView.text
  }
  
  func setEditMode() {
    mode.accept(.edit)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupView() {
    addSubview(topView)
    topView.addSubview(avatarImageView)
    topView.addSubview(userLabel)
    topView.addSubview(saveButton)
    topView.addSubview(editButton)
    topView.addSubview(cancelButton)
    topView.addSubview(deleteButton)
    addSubview(commentTextView)
    
    topView.snp.makeConstraints { (make) in
      make.top.equalTo(safeAreaLayoutGuide.snp.top)
      make.left.equalTo(safeAreaLayoutGuide.snp.left)
      make.right.equalTo(safeAreaLayoutGuide.snp.right)
      make.height.equalTo(UIScreen.main.bounds.height / 20)
    }
    
    avatarImageView.snp.makeConstraints { (make) in
      make.left.top.equalTo(topView).offset(5)
      make.bottom.equalTo(topView).offset(-5)
      make.width.equalTo(avatarImageView.snp.height)
    }
    
    commentTextView.snp.makeConstraints { (make) in
      make.left.equalTo(safeAreaLayoutGuide.snp.left)
      make.right.equalTo(safeAreaLayoutGuide.snp.right)
      make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
      make.top.equalTo(topView.snp.bottom)
    }
    
    userLabel.snp.makeConstraints { (make) in
      userLabel.sizeToFit()
      make.top.bottom.equalTo(topView)
      make.left.equalTo(avatarImageView.snp.right).offset(5)
    }
    
    editButton.snp.makeConstraints { (make) in
      editButton.sizeToFit()
      make.right.equalTo(topView).offset(-10)
      make.centerY.equalTo(topView)
    }
    
    saveButton.snp.makeConstraints { (make) in
      saveButton.sizeToFit()
      make.right.equalTo(topView).offset(-10)
      make.centerY.equalTo(topView)
    }
    
    cancelButton.snp.makeConstraints { (make) in
      cancelButton.sizeToFit()
      make.right.equalTo(saveButton.snp.left).offset(-10)
      make.centerY.equalTo(saveButton)
    }
    
    deleteButton.snp.makeConstraints { (make) in
      deleteButton.sizeToFit()
      make.right.equalTo(editButton.snp.left).offset(-10)
      make.centerY.equalTo(editButton)
    }
  }
  
}
