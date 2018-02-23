//
//  SidebarViewController.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 22..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SidebarViewController: UIViewController {
  private let bag = DisposeBag()
  var leftViewController: LeftViewController = {
    let vc = LeftViewController()
    return vc
  }()
  var mainViewController: MainViewController = {
    let vc = MainViewController()
    return vc
  }()
  var overlap: CGFloat = 70
  var scrollView: UIScrollView = {
    let view = UIScrollView()
    view.backgroundColor = UIColor.white
    view.isPagingEnabled = true
    view.bounces = false
    return view
  }()
  
  var contentView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.red
    return view
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    setupViewControllers()
    bindUI()
  }
  
  func setupView() {
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    
    scrollView.snp.makeConstraints { (make) in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
      make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
      make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
    }
    
    contentView.snp.makeConstraints { (make) in
      make.centerX.equalTo(view.frame.width - overlap / 2)
      make.centerY.equalTo(view)
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
    }
  }
  
  func setupViewControllers() {
    addViewController(leftViewController)
    addViewController(mainViewController)
    
    leftViewController.view.snp.makeConstraints { (make) in
      make.left.top.bottom.equalTo(contentView)
      make.width.equalTo(view.frame.width - overlap)
      make.height.equalTo(view)
      make.right.equalTo(mainViewController.view.snp.left)
    }
    
    mainViewController.view.snp.makeConstraints { (make) in
      make.right.top.bottom.equalTo(contentView)
      make.width.equalTo(view.frame.width)
      make.height.equalTo(view)
    }
    let w = 2 * UIScreen.main.bounds.width - overlap
    let h = UIScreen.main.bounds.height
    
    scrollView.contentSize = CGSize(width: w, height: h)
  }
  
  private func addViewController(_ viewController: UIViewController) {
    contentView.addSubview(viewController.view)
    addChildViewController(viewController)
    viewController.didMove(toParentViewController: self)
  }
  
  func leftMenuIsOpened() -> Bool {
    return scrollView.contentOffset.x == 0
  }
  
  func openLeftMenuAnimated(_ animated: Bool) {
    scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
  }
  
  func closeLeftMenuAnimated(_ animated: Bool) {
    scrollView.setContentOffset(CGPoint(x: leftViewController.view.frame.width, y: 0), animated: animated)
  }
  
  func toggleLeftMenuAnimated(_ animated: Bool) {
    if leftMenuIsOpened() {
      closeLeftMenuAnimated(animated)
    } else {
      openLeftMenuAnimated(animated)
    }
  }
  
  func bindUI() {
    mainViewController.menuButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [unowned self] in 
        self.toggleLeftMenuAnimated(true)
      })
      .disposed(by: bag)
  }
}
