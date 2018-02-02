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
    view.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
    view.rowHeight = 50
    return view
  }()
  
  private lazy var settingBarButtonItem: UIBarButtonItem = {
    let item = UIBarButtonItem(image: UIImage(named: "setting"),
                               style: .plain,
                               target: self,
                               action: nil)
    return item
  }()
  
  private lazy var activityIndicator: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView()
    spinner.color = UIColor.blue
    spinner.isHidden = false
    return spinner
  }()
  
  static func createWith(viewModel: RepoListViewViewModel) -> RepoListViewController {
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
    navigationItem.rightBarButtonItem = settingBarButtonItem
    view.backgroundColor = UIColor.white
    view.addSubview(tableView)
    view.addSubview(activityIndicator)
    
    tableView.snp.makeConstraints({ (make) in
      make.left.right.bottom.equalToSuperview()
      make.top.equalToSuperview().offset(50)
    })
    
    activityIndicator.snp.makeConstraints { (make) in
      make.width.height.equalTo(100)
      make.center.equalToSuperview()
    }
  }
  
  func bindUI() {
    viewModel.running.asDriver()
      .skip(1)
      .drive(activityIndicator.rx.isAnimating)
      .disposed(by:bag)
    
    settingBarButtonItem.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .map{ _ in true }
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { [weak self] _ in
        Navigator.shared.show(destination: .setting, sender: self!)
      })
      .disposed(by: bag)
  }
  
  func bindTableView() {
    viewModel.repoList.asDriver()
      .drive(onNext: { [weak self] _ in self?.tableView.reloadData() })
      .disposed(by: bag)
    
    //datasource
    viewModel.repoList.asObservable()
      .bind(to: tableView.rx.items) {
        [weak self] (tableView: UITableView, index: Int, element: Repository) in
        let cell = ListCell(style: .default, reuseIdentifier: ListCell.reuseIdentifier)
        cell.configureCell(viewModel: (self?.viewModel)!, index: index)
        return cell
    }
    .disposed(by: bag)
    
    //delegate
    tableView.rx.itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
        let selectedRepo = self?.viewModel.repoList.value[indexPath.row]
        Navigator.shared.show(destination: .issueList(selectedRepo!.id), sender: self!)
      })
      .disposed(by: bag)

  }
  
}
