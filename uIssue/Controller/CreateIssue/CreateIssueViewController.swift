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
  
  private lazy var submitButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("Submit new issue", for: UIControlState.normal)
    btn.setTitle("Enter title", for: UIControlState.disabled)
    btn.backgroundColor = UIColor.blue
    btn.isEnabled = false
    return btn
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
    view.addSubview(submitButton)
    
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
    
    submitButton.snp.makeConstraints { (make) in
      make.right.equalTo(commetTextView)
      make.height.equalTo(50)
      make.top.equalTo(commetTextView.snp.bottom).offset(10)
      make.width.equalTo(150)
    }
  }
  
  func bindUI() {
    //사용자 입력값을 뷰모델에 전달
    titleTextView.rx.text.orEmpty
      .bind(to: viewModel.titleInput)
      .disposed(by: bag)
    
    //뷰모델에서 가공된 결과를 받아서 바인딩
    viewModel.validate
      .drive(submitButton.rx.isEnabled)
      .disposed(by: bag)
    
    submitButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .do(onNext: { [weak self] in
        self?.viewModel.requestCreateIssue(title: (self?.titleTextView.text)!, comment: (self?.commetTextView.text)!, label: [.enhancement])
      })
      .observeOn(MainScheduler.instance)
      .bind(onNext: { [weak self] in
        self?.navigationController?.popViewController(animated: true)
      })
      .disposed(by: bag)
  }
}
