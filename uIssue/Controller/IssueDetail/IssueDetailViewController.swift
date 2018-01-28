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
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.layer.borderWidth = 1.0
    label.layer.borderColor = UIColor.black.cgColor
    label.text = viewModel.selectedIssue.title
    return label
  }()
  private lazy var commentLabel: UILabel = {
    let label = UILabel()
    label.layer.borderWidth = 1.0
    label.layer.borderColor = UIColor.black.cgColor
    label.text = viewModel.selectedIssue.body
    return label
  }()
  private lazy var closeButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("Close issue", for: UIControlState.normal)
    btn.backgroundColor = UIColor.red
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
    view.addSubview(titleLabel)
    view.addSubview(commentLabel)
    view.addSubview(closeButton)
    
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalToSuperview().offset(100)
      make.left.equalToSuperview().offset(50)
      make.right.equalToSuperview().offset(-50)
      make.height.equalTo(50)
    }
    
    commentLabel.snp.makeConstraints { (make) in
      make.left.right.equalTo(titleLabel)
      make.height.equalTo(200)
      make.top.equalTo(titleLabel.snp.bottom).offset(10)
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
        (self?.viewModel.editIssue(state: .closed, title: (self?.titleLabel.text!)!, comment: (self?.commentLabel.text!)!, label: [.enhancement]))!
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
        for i in 0..<commentArr.count {
          let commentBox = CommentBox(comment: commentArr[i], index: i)
          self?.view.addSubview(commentBox)
          commentBoxArr.append(commentBox)
        }
        for i in 0..<commentBoxArr.count {
          if i == 0 {
            commentBoxArr[i].snp.makeConstraints({ (make) in
              make.top.equalTo((self?.commentLabel.snp.bottom)!).offset(10)
              make.left.right.equalTo((self?.titleLabel)!)
              make.height.equalTo(100)
            })
          } else {
            commentBoxArr[i].snp.makeConstraints({ (make) in
              make.top.equalTo(commentBoxArr[i-1].snp.bottom).offset(10)
              make.left.right.equalTo((self?.titleLabel)!)
              make.height.equalTo(100)
            })
          }
        }
      })
      .subscribe()
      .disposed(by: bag)
  }
}
