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
  
  private let bodyTopLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = UIColor(hex: "2AA3EF")
    label.textColor = UIColor.white
    label.text = "Body"
    return label
  }()
  
  private let commmentsTopLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = UIColor(hex: "2AA3EF")
    label.textColor = UIColor.white
    label.text = "Comments"
    return label
  }()
  
  private let newCommmentTopLabel: UILabel = {
    let label = UILabel()
    label.backgroundColor = UIColor(hex: "2AA3EF")
    label.textColor = UIColor.white
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

  private let commentTableView: UITableView = {
    let view = UITableView()
    view.tableFooterView = UIView()
    view.register(CommentCell.self,
                  forCellReuseIdentifier: CommentCell.reuseIdentifier)
    return view
  }()
  
  private lazy var propertyBarButtonItem: UIBarButtonItem = {
    let item = UIBarButtonItem(image: UIImage(named: "setting"),
                               style: .plain,
                               target: self,
                               action: nil)
    return item
  }()
  
  private let closeButton: UIButton = {
    let btn = UIButton()
    btn.backgroundColor = UIColor(hex: "3CC75A")
    btn.layer.cornerRadius = 8
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
    
    //코멘트 가져오는건 한번만
    if viewModel.issueDetail.value.isCommentsFetched == nil {
      viewModel.requestFetchComments()
    }
    
    setupView()
    bindUI()
    bindTableView()
  }
  
  func setupView() {
    title = viewModel.issueDetail.value.title
    view.backgroundColor = UIColor.white
    navigationItem.rightBarButtonItem = propertyBarButtonItem
    view.addSubview(titleTextView)
    view.addSubview(bodyTopLabel)
    view.addSubview(bodyTextView)
    view.addSubview(commmentsTopLabel)
    view.addSubview(newCommmentTopLabel)
    view.addSubview(newCommentView)
    view.addSubview(commentTableView)
    view.addSubview(closeButton)
    
    titleTextView.snp.makeConstraints { (make) in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
      make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
    }
    
    bodyTopLabel.snp.makeConstraints { (make) in
      make.top.equalTo(titleTextView.snp.bottom)
      make.left.right.equalTo(titleTextView)
      make.height.equalTo(UIScreen.main.bounds.height / 20)
    }
    
    bodyTextView.snp.makeConstraints { (make) in
      make.left.right.equalTo(titleTextView)
      make.top.equalTo(bodyTopLabel.snp.bottom)
    }
    
    commmentsTopLabel.snp.makeConstraints { (make) in
      make.top.equalTo(bodyTextView.snp.bottom)
      make.left.right.equalTo(titleTextView)
      make.height.equalTo(bodyTopLabel)
    }
    
    commentTableView.snp.makeConstraints { (make) in
      make.top.equalTo(commmentsTopLabel.snp.bottom)
      make.left.right.equalTo(titleTextView)
      make.bottom.equalTo(newCommmentTopLabel.snp.top)
    }
    
    newCommmentTopLabel.snp.makeConstraints { (make) in
      make.left.right.equalTo(titleTextView)
      make.height.equalTo(bodyTopLabel)
      make.bottom.equalTo(newCommentView.snp.top)
    }
    
    newCommentView.snp.makeConstraints { (make) in
      make.left.right.equalTo(titleTextView)
      make.bottom.equalTo(closeButton.snp.top).offset(-10)
    }
    
    closeButton.snp.makeConstraints { (make) in
      make.height.equalTo(UIScreen.main.bounds.height / 30)
      make.width.equalTo(150)
      make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-10)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
    }
  }
  
  func bindUI() {
    //세팅버튼 탭하면 팝업
    propertyBarButtonItem.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        self?.presentPropertyViewController()
      })
      .disposed(by: bag)
    
    //이슈 상태에 따라서 버튼명 변경
    viewModel.issueDetail.asDriver()
      .drive(onNext: { [weak self] issue in
        self?.title = issue.title
        if issue.state == "closed" {
          self?.closeButton.setTitle("REOPEN ISSUE", for: UIControlState.normal)
          self?.propertyBarButtonItem.isEnabled = false
        } else {
          self?.closeButton.setTitle("CLOSE ISSUE", for: UIControlState.normal)
          self?.propertyBarButtonItem.isEnabled = true
        }
      }).disposed(by: bag)
    
    //close 탭시 이슈 상태 변경 요청해서 성공하면 화면 나가기
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
      CGSize(width: UIScreen.main.bounds.width - 50,
             height: UIScreen.main.bounds.height / 2)
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
