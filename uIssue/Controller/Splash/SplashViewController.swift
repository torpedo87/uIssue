//
//  SplashViewController.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 22..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SplashViewController: UIViewController {
  
  private let bag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bindUI()
  }
  
  func bindUI() {
    UserNetworkManager.status
      .drive(onNext: { [weak self] (status) in
        switch status {
        case .authorized:
          Navigator.shared.show(destination: .repoList, sender: self!)
        case .unAuthorized:
          Navigator.shared.show(destination: .login, sender: self!)
        }
      })
      .disposed(by: bag)
  }
}
