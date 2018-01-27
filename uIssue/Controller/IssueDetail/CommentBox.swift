//
//  CommentBox.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 26..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit

class CommentBox: UIView {
  
  private var comment: Comment!
  private var index: Int!
  
  enum Mode {
    case normal
    case edit
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
    return btn
  }()
  
  private lazy var commentTextView: UITextView = {
    let view = UITextView()
    return view
  }()
  
  init(comment: Comment, index: Int) {
    self.comment = comment
    self.index = index
    super.init(frame: CGRect.zero)
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupView() {
    addSubview(topView)
    topView.addSubview(userLabel)
    topView.addSubview(editButton)
    addSubview(commentTextView)
    
    userLabel.text = comment.user.login
    commentTextView.text = comment.body
    
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
  }
}
