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
  
  private lazy var titleTextView: CommentBoxView = {
    let issue = viewModel.issueDetail.value
    let commentBox = CommentBoxView(comment: nil,
                                    issue: issue,
                                    contentsMode: .issueTitle,
                                    viewModel: viewModel)
    return commentBox
  }()
  
  private lazy var bodyTopLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = UIColor(hex: "FEDF32")
    label.text = "Body"
    return label
  }()
  
  private lazy var commmentsTopLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = UIColor(hex: "FEDF32")
    label.text = "Comments"
    return label
  }()
  
  private lazy var newCommmentTopLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = UIColor(hex: "FEDF32")
    label.text = "New Comment"
    return label
  }()
  
  private lazy var bodyTextView: CommentBoxView = {
    let issue = viewModel.issueDetail.value
    let commentBox = CommentBoxView(comment: nil,
                                    issue: issue,
                                    contentsMode: .issueBody,
                                    viewModel: viewModel)
    return commentBox
  }()
  
  private lazy var newCommentView: CommentBoxView = {
    let emptyComment =
      Comment(id: 1, user: Me.shared.getUser()!, created_at: "", body: "")
    let commentBox = CommentBoxView(comment: emptyComment,
                                    issue: nil,
                                    contentsMode: .newCommentBody,
                                    viewModel: viewModel)
    commentBox.setEditMode()
    return commentBox
  }()

  private lazy var commentTableView: UITableView = {
    let view = UITableView()
    view.tableFooterView = UIView()
    view.register(CommentCell.self,
                  forCellReuseIdentifier: CommentCell.reuseIdentifier)
    return view
  }()
  
  private lazy var settingBarButtonItem: UIBarButtonItem = {
    let item = UIBarButtonItem(image: UIImage(named: "setting"),
                               style: .plain,
                               target: self,
                               action: nil)
    return item
  }()
  
  private lazy var closeButton: UIButton = {
    let btn = UIButton()
    btn.backgroundColor = UIColor(hex: "3CC75A")
    return btn
  }()
  
  static func createWith(
    viewModel: IssueDetailViewViewModel) -> IssueDetailViewController {
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
    navigationItem.rightBarButtonItem = settingBarButtonItem
    view.addSubview(titleTextView)
    view.addSubview(bodyTopLabel)
    view.addSubview(bodyTextView)
    view.addSubview(commmentsTopLabel)
    view.addSubview(newCommmentTopLabel)
    view.addSubview(newCommentView)
    view.addSubview(commentTableView)
    view.addSubview(closeButton)
    
    titleTextView.snp.makeConstraints { (make) in
      make.top.equalToSuperview().offset(85)
      make.left.right.equalToSuperview()
    }
    
    bodyTopLabel.snp.makeConstraints { (make) in
      make.top.equalTo(titleTextView.snp.bottom)
      make.left.right.equalToSuperview()
      make.height.equalTo(30)
    }
    
    bodyTextView.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.top.equalTo(bodyTopLabel.snp.bottom)
    }
    
    commmentsTopLabel.snp.makeConstraints { (make) in
      make.top.equalTo(bodyTextView.snp.bottom)
      make.left.right.equalToSuperview()
      make.height.equalTo(30)
    }
    
    commentTableView.snp.makeConstraints { (make) in
      make.top.equalTo(commmentsTopLabel.snp.bottom)
      make.left.right.equalToSuperview()
      make.bottom.equalTo(newCommmentTopLabel.snp.top)
    }
    
    newCommmentTopLabel.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.height.equalTo(30)
      make.bottom.equalTo(newCommentView.snp.top)
    }
    
    newCommentView.snp.makeConstraints { (make) in
      make.left.right.equalToSuperview()
      make.bottom.equalTo(closeButton).offset(-50)
    }
    
    closeButton.snp.makeConstraints { (make) in
      closeButton.sizeToFit()
      make.right.bottom.equalToSuperview().offset(-20)
    }
  }
  
  func bindUI() {
    
    settingBarButtonItem.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        self?.presentPropertyViewController()
      })
      .disposed(by: bag)
    
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
          let labels = IssueService().transformIssueLabelToLabel(
            issueLabelArr: issue.labels)
          if issue.state == "closed" {
            return (self?.viewModel.editIssue(state: .open,
                                              newTitleText: issue.title,
                                              newBodyText: issue.body!,
                                              label: labels,
                                              assignees: issue.assignees))!
          } else {
            return (self?.viewModel.editIssue(state: .closed,
                                              newTitleText: issue.title,
                                              newBodyText: issue.body!,
                                              label: labels,
                                              assignees: issue.assignees))!
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
      .drive(onNext: { [weak self] _ in
        self?.commentTableView.reloadData()
      })
      .disposed(by: bag)
    
    //datasource
    viewModel.commentList.asObservable()
      .observeOn(MainScheduler.instance)
      .bind(to: commentTableView.rx.items) {
        [weak self] (tableView: UITableView, index: Int, element: Comment) in
        let cell = CommentCell(comment: element, viewModel: (self?.viewModel)!)
        return cell
      }
      .disposed(by: bag)
    
  }
  
  func presentPropertyViewController() {
    let issuePropertyViewController =
      IssuePropertyViewController.createWith(viewModel: viewModel)
    issuePropertyViewController.modalPresentationStyle = .popover
    issuePropertyViewController.preferredContentSize =
      CGSize(width: UIScreen.main.bounds.width - 20, height: 500)
    let popOver = issuePropertyViewController.popoverPresentationController
    popOver?.delegate = self
    popOver?.sourceView = view
    popOver?.sourceRect = CGRect(origin: view.center, size: CGSize.zero)
    popOver?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
    present(issuePropertyViewController, animated: true, completion: nil)
  }
}

extension IssueDetailViewController: UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyle(
    for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }
}
