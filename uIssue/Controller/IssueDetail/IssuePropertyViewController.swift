//
//  IssuePropertyViewController.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 8..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class IssuePropertyViewController: UIViewController {
  
  private var viewModel: PropertySettable!
  private let bag = DisposeBag()
  
  static func createWith(
    viewModel: PropertySettable) -> IssuePropertyViewController {
    return {
      $0.viewModel = viewModel
      return $0
      }(IssuePropertyViewController())
  }
  
  private lazy var propertyView: IssuePropertyView = {
    let view = IssuePropertyView(viewModel: viewModel)
    return view
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  func setupView() {
    view.addSubview(propertyView)
    
    propertyView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
  }
}
