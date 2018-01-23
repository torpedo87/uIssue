//
//  IssueDetailViewController.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 23..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit

class IssueDetailViewController: UIViewController {
  private var viewModel: IssueDetailViewViewModel!
  
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
  }
  
  func bindUI() {
    
  }
}
