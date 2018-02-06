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
  private let topView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(hex: "FEDF32")
    return view
  }()
  
  private lazy var titleTextField: UITextField = {
    let view = UITextField()
    view.placeholder = "Leave a new issue"
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
  
  private lazy var cancelButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("CANCEL", for: UIControlState.normal)
    btn.setTitleColor(UIColor.black, for: UIControlState.normal)
    return btn
  }()
  
  private lazy var submitButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("Submit new issue", for: UIControlState.normal)
    btn.setTitleColor(UIColor.black, for: UIControlState.normal)
    btn.setTitleColor(UIColor.lightGray, for: UIControlState.disabled)
    btn.setTitle("Enter title", for: UIControlState.disabled)
    btn.isEnabled = false
    return btn
  }()
  
  private lazy var propertyView: IssuePropertyView = {
    let view = IssuePropertyView(viewModel: viewModel)
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
    view.addSubview(topView)
    topView.addSubview(cancelButton)
    topView.addSubview(submitButton)
    view.backgroundColor = UIColor.white
    view.addSubview(titleTextField)
    view.addSubview(commetTextView)
    view.addSubview(propertyView)
    
    topView.snp.makeConstraints { (make) in
      make.left.top.right.equalToSuperview()
      make.height.equalTo(85)
    }
    
    titleTextField.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.height.equalTo(50)
      make.left.equalToSuperview().offset(50)
      make.right.equalToSuperview().offset(-50)
      make.top.equalTo(topView.snp.bottom).offset(10)
    }
    
    commetTextView.snp.makeConstraints { (make) in
      make.centerX.left.right.equalTo(titleTextField)
      make.height.equalTo(200)
      make.top.equalTo(titleTextField.snp.bottom).offset(10)
    }
    
    cancelButton.snp.makeConstraints { (make) in
      cancelButton.sizeToFit()
      make.left.equalTo(topView).offset(10)
      make.bottom.equalTo(topView).offset(-5)
    }
    
    submitButton.snp.makeConstraints { (make) in
      submitButton.sizeToFit()
      make.right.equalTo(topView).offset(-10)
      make.bottom.equalTo(topView).offset(-5)
    }
    
    propertyView.snp.makeConstraints { (make) in
      make.left.right.equalTo(commetTextView)
      make.top.equalTo(commetTextView.snp.bottom).offset(10)
      make.bottom.equalToSuperview().offset(-50)
    }
    
  }
  
  func bindUI() {
    //사용자 입력값을 뷰모델에 전달
    titleTextField.rx.text.orEmpty
      .bind(to: viewModel.titleInput)
      .disposed(by: bag)
    
    //뷰모델에서 가공된 결과를 받아서 바인딩
    viewModel.validate
      .drive(submitButton.rx.isEnabled)
      .disposed(by: bag)
    
    
    submitButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<Bool> in
        let checkedLabels = IssueService().getCheckedLabels(items: (self?.viewModel.labelItems.value)!)
        let checkedUsers = IssueService().getCheckedUsers(items: (self?.viewModel.assigneeItems.value)!)
        return (self?.viewModel.createIssue(title: (self?.titleTextField.text)!, newComment: (self?.commetTextView.text)!, label: checkedLabels, users: checkedUsers))!
      }
      .debug()
      .observeOn(MainScheduler.instance)
      .bind { [weak self] (success) in
        if success {
          self?.dismiss(animated: true, completion: nil)
        }
      }.disposed(by: bag)
    
    cancelButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        self?.dismiss(animated: true, completion: nil)
      })
      .disposed(by: bag)
    
  }
  
}
