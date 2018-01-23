//
//  CreateIssueViewController.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 23..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CreateIssueViewController: UIViewController {
  
  private var viewModel: CreateIssueViewViewModel!
  private let bag = DisposeBag()
  private lazy var titleTextView: UITextView = {
    let view = UITextView()
    view.layer.borderWidth = 1.0
    view.layer.borderColor = UIColor.black.cgColor
    return view
  }()
  
  private lazy var commetTextView: UITextView = {
    let view = UITextView()
    view.layer.borderWidth = 1.0
    view.layer.borderColor = UIColor.black.cgColor
    return view
  }()
  
  static func createWith(viewModel: CreateIssueViewViewModel) -> CreateIssueViewController {
    return {
      $0.viewModel = viewModel
      return $0
      }(CreateIssueViewController())
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    bindUI()
  }
  
  func setupView() {
    title = "Create Issue"
    view.backgroundColor = UIColor.white
    view.addSubview(titleTextView)
    view.addSubview(commetTextView)
    
    titleTextView.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.height.equalTo(50)
      make.left.equalToSuperview().offset(50)
      make.right.equalToSuperview().offset(-50)
      make.top.equalToSuperview().offset(100)
    }
    
    commetTextView.snp.makeConstraints { (make) in
      make.centerX.left.right.equalTo(titleTextView)
      make.height.equalTo(200)
      make.top.equalTo(titleTextView.snp.bottom).offset(10)
    }
  }
  
  func bindUI() {
    
  }
}
