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
      .drive(onNext: { [unowned self] _ in
        self.cancelWithMode(mode: self.contentsMode)
      })
      .disposed(by: bag)
    
    //삭제버튼 탭시 삭제 요청하기
    deleteButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .flatMap { [unowned self] _ -> Observable<Bool> in
        self.deleteWithMode(mode: self.contentsMode)
      }.asDriver(onErrorJustReturn: false)
      .drive(onNext: { [unowned self] bool in
        if bool {
          switch (self.contentsMode)! {
          case .issueBody:
            self.commentTextView.text = ""
          case .newCommentBody:
            self.commentTextView.text = ""
          default: break
          }
        }
      })
      .disposed(by: bag)
    
    //편집버튼 탭
    editButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [unowned self] _ in
        self.mode.accept(.edit)
      })
      .disposed(by: bag)
    
    //저장버튼 탭
    saveButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .observeOn(MainScheduler.instance)
      .flatMap { [unowned self] _ -> Observable<Bool> in
        self.saveWithMode(mode: self.contentsMode)
      }.asDriver(onErrorJustReturn: false)
      .drive(onNext: { [unowned self] (success) in
        if success {
          switch (self.contentsMode)! {
          case .newCommentBody:
            self.commentTextView.text = ""
          default:
            self.mode.accept(.normal)
          }
        }
      })
      .disposed(by: bag)
    
    
    //edit or normal
    mode.asDriver()
      .drive(onNext: { [unowned self] modeValue in
        self.configureWithMode(modeValue: modeValue)
      })
      .disposed(by: bag)
    
    configureWithContentsMode(mode: contentsMode)
  }
  
  private func cancelWithMode(mode: Contents) {
    switch mode {
    case .issueBody:
      self.commentTextView.text = self.viewModel.issueDetail.value.body
    case .commentBody:
      self.commentTextView.text = self.comment?.body
    case .newCommentBody:
      self.commentTextView.text = ""
    case .issueTitle:
      self.commentTextView.text = self.issue?.title
    }
    self.mode.accept(.normal)
  }
  
  private func deleteWithMode(mode: Contents) -> Observable<Bool> {
    let issue = viewModel.issueDetail.value
    let issueState =
      IssueService().transformStrToState(stateString: issue.state)
    let issueLabel =
      IssueService().transformIssueLabelToLabel(issueLabelArr: issue.labels)
    switch self.contentsMode {
    case .issueBody:
      return self.viewModel.editIssue(state: issueState!,
                                        newTitleText: issue.title,
                                        newBodyText: "",
                                        label: issueLabel,
                                        assignees: issue.assignees)
    case .commentBody:
      return self.viewModel.deleteComment(existingComment: self.comment!)
      
    default:
      return Observable.just(false)
    }
    
  }
  
  private func saveWithMode(mode: Contents) -> Observable<Bool> {
    let assignees = self.viewModel.issueDetail.value.assignees
    let issueLabels = self.viewModel.issueDetail.value.labels
    let labels =
      IssueService().transformIssueLabelToLabel(issueLabelArr: issueLabels)
    switch mode {
    case .issueBody:
      return self.viewModel.editIssue(state: .open,
                                      newTitleText: self.issue!.title,
                                      newBodyText: self.commentTextView.text,
                                      label: labels,
                                      assignees: assignees)
      
    case .commentBody:
      return self.viewModel.editComment(existingComment: self.comment!,
                                        newCommentText: self.commentTextView.text)
      
    case .newCommentBody:
      return self.viewModel.createComment(newCommentBody: self.commentTextView.text)
      
    case .issueTitle:
      return self.viewModel.editIssue(state: .open,
                                      newTitleText: self.commentTextView.text,
                                      newBodyText: self.issue!.body ?? "",
                                      label: labels,
                                      assignees: assignees)
    }
  }
  
  private func configureWithContentsMode(mode: Contents) {
    switch mode {
    case .commentBody:
      let imgUrl = URL(string: self.comment!.user.avatar_url)
      self.avatarImageView.kf.setImage(with: imgUrl)
      self.userLabel.text = self.comment!.user.login
      self.commentTextView.text = self.comment!.body
      
    case .issueBody:
      let imgUrl = URL(string: self.issue!.user.avatar_url)
      self.avatarImageView.kf.setImage(with: imgUrl)
      self.userLabel.text = self.issue!.user.login
      self.commentTextView.text = self.issue!.body
      
    case .newCommentBody:
      let me = Me.shared.getUser()
      let imgUrl = URL(string: me!.avatar_url)
      self.avatarImageView.kf.setImage(with: imgUrl)
      self.userLabel.text = me!.login
      self.commentTextView.text = ""
      
    case .issueTitle:
      let me = Me.shared.getUser()
      let imgUrl = URL(string: me!.avatar_url)
      self.avatarImageView.kf.setImage(with: imgUrl)
      self.userLabel.text = me!.login
      self.commentTextView.text = self.issue!.title
    }
  }
  
  private func configureWithMode(modeValue: Mode) {
    switch modeValue {
    case .edit:
      self.commentTextView.isUserInteractionEnabled = true
      self.commentTextView.backgroundColor = UIColor(hex: "FCFCA8")
      self.editButton.isHidden = true
      self.deleteButton.isHidden = true
      self.saveButton.isHidden = false
      self.cancelButton.isHidden = false
    case .normal:
      self.commentTextView.isUserInteractionEnabled = false
      self.commentTextView.backgroundColor = UIColor.white
      self.editButton.isHidden = false
      self.deleteButton.isHidden = false
      self.saveButton.isHidden = true
      self.cancelButton.isHidden = true
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
