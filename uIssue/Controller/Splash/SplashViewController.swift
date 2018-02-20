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
    view.backgroundColor = UIColor.white
    bindUI()
  }
  
  func bindUI() {
    
    //왜 드라이버를 사용하는 데에도 디스패치큐를 지정해줘야만 작동하지?
    AuthService().status
      .asDriver()
      .drive(onNext: { [unowned self] (status) in
        switch status {
        case .authorized:
          DispatchQueue.main.async {
            Navigator.shared.show(destination: .repoList, sender: self)
          }
        case .unAuthorized:
          DispatchQueue.main.async {
            Navigator.shared.show(destination: .login, sender: self)
          }
        }
      })
      .disposed(by: bag)
  }
}
