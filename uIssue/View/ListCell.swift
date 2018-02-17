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
    label.textAlignment = .center
    return label
  }()
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    addSubview(titleLabel)
    addSubview(countLabel)
    
    titleLabel.snp.makeConstraints { (make) in
      make.left.equalTo(safeAreaLayoutGuide.snp.left).offset(10)
      make.top.equalTo(safeAreaLayoutGuide.snp.top)
      make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
    }
    countLabel.snp.makeConstraints { (make) in
      countLabel.sizeToFit()
      make.left.equalTo(titleLabel.snp.right)
      make.right.equalTo(safeAreaLayoutGuide.snp.right)
      make.top.equalTo(safeAreaLayoutGuide.snp.top)
      make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func configureCell(viewModel: RepoListViewViewModel, index: Int) {
    titleLabel.text = viewModel.repoList.value[index].name
    countLabel.text = "\(viewModel.repoList.value[index].open_issues) opened"
  }
  
  func configureCell(viewModel: IssueListViewViewModel, index: Int) {
    titleLabel.text = viewModel.issueList.value[index].title
    countLabel.text = "# \(viewModel.issueList.value[index].number)"
  }
  
  func configureCell(list: [String], index: Int) {
    titleLabel.text = list[index]
  }
  
  func configureLabelCell(item: LabelItem) {
    titleLabel.text = item.label.rawValue
    if item.isChecked {
      accessoryType = .checkmark
    } else {
      accessoryType = .none
    }
  }
  
  func configureAssigneeCell(item: AssigneeItem) {
    titleLabel.text = item.user.login
    if item.isChecked {
      accessoryType = .checkmark
    } else {
      accessoryType = .none
    }
  }
}
