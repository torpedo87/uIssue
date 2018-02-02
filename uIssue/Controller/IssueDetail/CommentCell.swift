//
//  CommentCell.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 2..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CommentCell: UITableViewCell {
  
  static let reuseIdentifier = "CommentCell"
  var comment: Comment!
  var viewModel: IssueDetailViewViewModel!
  private lazy var commentView: CommentBoxView = {
    let view = CommentBoxView(comment: comment, issue: nil, contentsMode: CommentBoxView.Contents.commentBody, viewModel: viewModel)
    return view
  }()
  
  init(comment: Comment, viewModel: IssueDetailViewViewModel) {
    self.comment = comment
    self.viewModel = viewModel
    super.init(style: .default, reuseIdentifier: CommentCell.reuseIdentifier)
    
    addSubview(commentView)
    
    commentView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    commentView.setEmpty()
  }
}
