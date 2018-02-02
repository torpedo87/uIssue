//
//  IssueListViewController.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 20..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class IssueListViewController: UIViewController {
  private let bag = DisposeBag()
  private var viewModel: IssueListViewViewModel!
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
  private lazy var newIssueButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("+", for: UIControlState.normal)
    btn.backgroundColor = UIColor.red
    btn.layer.cornerRadius = 25
    return btn
  }()
  
  static func createWith(viewModel: IssueListViewViewModel) -> IssueListViewController {
    return {
      $0.viewModel = viewModel
      return $0
      }(IssueListViewController())
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    bindUI()
    bindTableView()
  }
  
  func setupView() {
    title = "Issue List"
    navigationItem.rightBarButtonItem = settingBarButtonItem
    view.backgroundColor = UIColor.white
    view.addSubview(tableView)
    view.addSubview(newIssueButton)
    
    tableView.snp.makeConstraints({ (make) in
      make.left.right.bottom.equalToSuperview()
      make.top.equalToSuperview().offset(50)
    })
    
    newIssueButton.snp.makeConstraints({ (make) in
      make.width.height.equalTo(50)
      make.right.bottom.equalToSuperview().offset(-30)
    })
  }
  
  func bindUI() {
    
    settingBarButtonItem.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .map{ _ in true }
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { [weak self] _ in
        Navigator.shared.show(destination: .setting, sender: self!)
      })
      .disposed(by: bag)
    
    newIssueButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .map{ _ in true }
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { [weak self] _ in
        let repoId = self?.viewModel.repoId
        Navigator.shared.show(destination: .createIssue(repoId!), sender: self!)
      })
      .disposed(by: bag)
  }
  
  func bindTableView() {
    viewModel.issueList.asDriver()
      .drive(onNext: { [weak self] _ in self?.tableView.reloadData() })
      .disposed(by: bag)
    
    //datasource
    viewModel.issueList.asObservable()
      .bind(to: tableView.rx.items) {
        [weak self] (tableView: UITableView, index: Int, element: Issue) in
        let cell = ListCell(style: .default, reuseIdentifier: ListCell.reuseIdentifier)
        cell.configureCell(viewModel: (self?.viewModel)!, index: index)
        return cell
      }
      .disposed(by: bag)
    
    //delegate
    tableView.rx
      .itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        let repoId = self?.viewModel.repoId
        self?.tableView.deselectRow(at: indexPath, animated: true)
        let selectedIssue = self?.viewModel.issueList.value[indexPath.row]
        Navigator.shared.show(destination: .issueDetail(repoId!, selectedIssue!.id), sender: self!)
      })
      .disposed(by: bag)
  }
  
}
