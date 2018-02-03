//
//  ListCell.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 29..
//  Copyright © 2017년 samchon. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {
  
  static let reuseIdentifier = "ListCell"
  private let titleLabel: UILabel = {
    let label = UILabel()
    return label
  }()
  private let countLabel: UILabel = {
    let label = UILabel()
    return label
  }()
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    addSubview(titleLabel)
    addSubview(countLabel)
    
    titleLabel.snp.makeConstraints { (make) in
      make.right.equalTo(countLabel.snp.left)
      make.left.top.bottom.equalToSuperview()
    }
    countLabel.snp.makeConstraints { (make) in
      make.width.equalTo(50)
      make.right.top.bottom.equalToSuperview()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configureCell(viewModel: RepoListViewViewModel, index: Int) {
    titleLabel.text = viewModel.repoList.value[index].name
    countLabel.text = "\(viewModel.repoList.value[index].issuesDic!.count) 개"
  }
  
  func configureCell(viewModel: IssueListViewViewModel, index: Int) {
    titleLabel.text = viewModel.issueList.value[index].title
    countLabel.text = "# \(viewModel.issueList.value[index].number)"
  }
}
