//
//  RepoListViewController.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RepoListViewController: UIViewController {
  private let bag = DisposeBag()
  private var viewModel: RepoListViewViewModel!
  private lazy var tableView: UITableView = {
    let view = UITableView()
    view.register(ListCell.self,
                  forCellReuseIdentifier: ListCell.reuseIdentifier)
    view.rowHeight = UIScreen.main.bounds.height / 20
    return view
  }()
  
  private lazy var logoutBarButtonItem: UIBarButtonItem = {
    let item = UIBarButtonItem(title: "LOGOUT",
                               style: .plain,
                               target: self,
                               action: nil)
    return item
  }()
  
  private let activityIndicator: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView()
    spinner.color = UIColor.blue
    spinner.isHidden = false
    return spinner
  }()
  
  static func createWith(
    viewModel: RepoListViewViewModel) -> RepoListViewController {
    return {
      $0.viewModel = viewModel
      return $0
      }(RepoListViewController())
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    bindUI()
    bindTableView()
  }
  
  func setupView() {
    title = "Repository List"
    navigationItem.rightBarButtonItem = logoutBarButtonItem
    view.backgroundColor = UIColor.white
    view.addSubview(tableView)
    view.addSubview(activityIndicator)
    
    tableView.snp.makeConstraints({ (make) in
      make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
      make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
    })
    
    activityIndicator.snp.makeConstraints { (make) in
      make.width.height.equalTo(UIScreen.main.bounds.height / 10)
      make.center.equalToSuperview()
    }
  }
  
  func bindUI() {
    
    viewModel.running.asDriver()
      .drive(activityIndicator.rx.isAnimating)
      .disposed(by: bag)
    
    //로그아웃 버튼 클릭시 로그아웃 화면으로 이동
    logoutBarButtonItem.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [unowned self] _ in
        Navigator.shared.show(destination: .setting, sender: self)
      })
      .disposed(by: bag)
  }
  
  func bindTableView() {
    viewModel.repoList.asDriver()
      .drive(onNext: { [unowned self] _ in self.tableView.reloadData() })
      .disposed(by: bag)
    
    //datasource
    viewModel.repoList.asObservable()
      .bind(to: tableView.rx.items) {
        [unowned self] (tableView: UITableView, index: Int, element: Repository) in
        let cell =
          ListCell(style: .default, reuseIdentifier: ListCell.reuseIdentifier)
        cell.configureCell(viewModel: self.viewModel, index: index)
        return cell
    }
    .disposed(by: bag)
    
    //delegate
    tableView.rx.itemSelected
      .subscribe(onNext: { [unowned self] indexPath in
        self.tableView.deselectRow(at: indexPath, animated: true)
        let selectedRepo = self.viewModel.repoList.value[indexPath.row]
        Navigator.shared.show(destination: .issueList(selectedRepo.id),
                              sender: self)
      })
      .disposed(by: bag)

  }
  
}
