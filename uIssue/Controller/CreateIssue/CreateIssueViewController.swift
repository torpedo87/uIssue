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
  
  private let topBar: UIToolbar = {
    let bar = UIToolbar(frame: CGRect.zero)
    return bar
  }()
  
  private let titleTextField: UITextField = {
    let view = UITextField()
    view.placeholder = "Leave a new issue"
    view.layer.borderWidth = 1.0
    view.layer.borderColor = UIColor.black.cgColor
    return view
  }()
  
  private let commetTextView: UITextView = {
    let view = UITextView()
    view.layer.borderWidth = 1.0
    view.text = ""
    view.layer.borderColor = UIColor.black.cgColor
    view.isScrollEnabled = false
    return view
  }()
  
  private let cancelButton: UIButton = {
    let btn = UIButton()
    btn.backgroundColor = UIColor(hex: "3CC75A")
    btn.layer.cornerRadius = 8
    btn.setTitle("CANCEL", for: UIControlState.normal)
    btn.setTitleColor(UIColor.white, for: UIControlState.normal)
    return btn
  }()
  
  private let submitButton: UIButton = {
    let btn = UIButton()
    btn.backgroundColor = UIColor(hex: "3CC75A")
    btn.layer.cornerRadius = 8
    btn.setTitle("Submit new issue", for: UIControlState.normal)
    btn.setTitle("Enter title", for: UIControlState.disabled)
    btn.isEnabled = false
    return btn
  }()
  
  private lazy var propertyBarButtonItem: UIBarButtonItem = {
    let item = UIBarButtonItem(image: UIImage(named: "setting"),
                               style: .plain,
                               target: self,
                               action: nil)
    return item
  }()
  
  private lazy var propertyView: IssuePropertyView = {
    let view = IssuePropertyView(viewModel: viewModel)
    return view
  }()
  
  static func createWith(
    viewModel: CreateIssueViewViewModel) -> CreateIssueViewController {
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
    view.backgroundColor = UIColor.white
    view.addSubview(topBar)
    topBar.setItems([propertyBarButtonItem], animated: true)
    view.addSubview(titleTextField)
    view.addSubview(commetTextView)
    view.addSubview(propertyView)
    view.addSubview(submitButton)
    view.addSubview(cancelButton)
    
    topBar.snp.makeConstraints { (make) in
      make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
      make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      make.height.equalTo(UIScreen.main.bounds.height / 15)
    }
    
    titleTextField.snp.makeConstraints { (make) in
      make.centerX.equalToSuperview()
      make.height.equalTo(UIScreen.main.bounds.height / 20)
      make.width.equalTo(UIScreen.main.bounds.width * 2 / 3)
      make.top.equalTo(topBar.snp.bottom).offset(20)
    }
    
    commetTextView.snp.makeConstraints { (make) in
      make.centerX.left.right.equalTo(titleTextField)
      make.top.equalTo(titleTextField.snp.bottom).offset(20)
    }
    
    submitButton.snp.makeConstraints { (make) in
      make.right.equalTo(commetTextView)
      make.height.equalTo(UIScreen.main.bounds.height / 20)
      make.top.equalTo(commetTextView.snp.bottom).offset(20)
    }
    
    cancelButton.snp.makeConstraints { (make) in
      make.left.equalTo(commetTextView)
      make.height.width.centerY.equalTo(submitButton)
      make.right.equalTo(submitButton.snp.left).offset(-10)
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
    
    //세팅 탭하면 팝업
    propertyBarButtonItem.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        self?.presentPropertyViewController()
      })
      .disposed(by: bag)
    
    //버튼 클릭시 새이슈생성 요청해서 성공하면 화면 dismiss
    submitButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .flatMap { [weak self] _ -> Observable<Bool> in
        let checkedLabelItems =
          Array((self?.viewModel)!.labelItemsDict.value
            .filter { $0.value.isChecked }.values)
        let checkedLabels = checkedLabelItems.map { $0.label }
        let checkedAssigneeItems =
          Array((self?.viewModel)!.assigneeItemsDict.value
            .filter { $0.value.isChecked }.values)
        let checkedUsers = checkedAssigneeItems.map{ $0.user }
        return (self?.viewModel.createIssue(title: (self?.titleTextField.text)!,
                                            newComment: (self?.commetTextView.text)!,
                                            label: checkedLabels,
                                            users: checkedUsers))!
      }
      .observeOn(MainScheduler.instance)
      .bind { [weak self] (success) in
        if success {
          self?.dismiss(animated: true, completion: nil)
        }
      }.disposed(by: bag)
    
    //cancel 버튼 클릭시 화면 나가기
    cancelButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        self?.dismiss(animated: true, completion: nil)
      })
      .disposed(by: bag)
    
  }
  
  func presentPropertyViewController() {
    let issuePropertyViewController =
      IssuePropertyViewController.createWith(viewModel: viewModel)
    issuePropertyViewController.modalPresentationStyle = .popover
    issuePropertyViewController.preferredContentSize =
      CGSize(width: UIScreen.main.bounds.width - 20,
             height: UIScreen.main.bounds.height / 2)
    let popOver = issuePropertyViewController.popoverPresentationController
    popOver?.delegate = self
    popOver?.sourceView = view
    popOver?.sourceRect = CGRect(origin: view.center, size: CGSize.zero)
    popOver?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
    present(issuePropertyViewController, animated: true, completion: nil)
  }
  
}

extension CreateIssueViewController: UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyle(
    for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }
}
