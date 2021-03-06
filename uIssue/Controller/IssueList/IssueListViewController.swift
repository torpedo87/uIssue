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
  
  private let topBar: UIToolbar = {
    let bar = UIToolbar(frame: CGRect.zero)
    return bar
  }()

  private lazy var stateButton: UIBarButtonItem = {
    let item = UIBarButtonItem(title: "STATE ▽",
                              style: UIBarButtonItemStyle.plain,
                              target: self,
                              action: nil)
    return item
  }()
  
  private lazy var sortButton: UIBarButtonItem = {
    let item = UIBarButtonItem(title: "SORT ▽",
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: nil)
    return item
  }()
  
  private let labelButton: UIBarButtonItem = {
    let item = UIBarButtonItem(title: "LABEL ▽",
                               style: UIBarButtonItemStyle.plain,
                               target: self,
                               action: nil)
    return item
  }()
  
  private let tableView: UITableView = {
    let view = UITableView()
    view.register(ListCell.self,
                  forCellReuseIdentifier: ListCell.reuseIdentifier)
    view.rowHeight = UIScreen.main.bounds.height / 20
    return view
  }()
  
  private lazy var addBarButtonItem: UIBarButtonItem = {
    let item =
      UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add,
                      target: self,
                      action: nil)
    return item
  }()
  
  static func createWith(
    viewModel: IssueListViewViewModel) -> IssueListViewController {
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
    navigationItem.rightBarButtonItem = addBarButtonItem
    view.backgroundColor = UIColor.white
    view.addSubview(topBar)
    topBar.setItems([stateButton, sortButton, labelButton], animated: true)
    view.addSubview(tableView)
    
    topBar.snp.makeConstraints { (make) in
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
      make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
      make.height.equalTo(UIScreen.main.bounds.height / 20)
    }
    
    tableView.snp.makeConstraints({ (make) in
      make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
      make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
      make.top.equalTo(topBar.snp.bottom)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
    })
    
  }
  
  func bindUI() {
    
    //state 누르면 팝업
    stateButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        self?.presentPopUp(sender: (self?.stateButton)!, mode: .state)
      })
      .disposed(by: bag)
    
    //sort 누르면 팝업
    sortButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        self?.presentPopUp(sender: (self?.sortButton)!, mode: .sort)
      })
      .disposed(by: bag)
    
    //label 누르면 팝업
    labelButton.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        self?.presentPopUp(sender: (self?.labelButton)!, mode: .label)
      })
      .disposed(by: bag)
    
    //add 누르면 createIssue 화면으로 이동
    addBarButtonItem.rx.tap
      .throttle(0.5, scheduler: MainScheduler.instance)
      .asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] _ in
        let repoId = self?.viewModel.repoId
        Navigator.shared.show(destination: .createIssue(repoId!),
                              sender: self!)
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
        let cell = ListCell(style: .default,
                            reuseIdentifier: ListCell.reuseIdentifier)
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
        Navigator.shared.show(destination: .issueDetail(repoId!, selectedIssue!.id),
                              sender: self!)
      })
      .disposed(by: bag)
  }
  
  func presentPopUp(sender: UIBarButtonItem, mode: PopUpViewController.PopUpMode) {
    let popUpViewController =
      PopUpViewController.createWith(viewModel: viewModel, mode: mode)
    popUpViewController.modalPresentationStyle = .popover
    popUpViewController.preferredContentSize =
      CGSize(width: 100, height: popUpViewController.getTableViewHeight())
    let popOver = popUpViewController.popoverPresentationController
    popOver?.delegate = self
    popOver?.barButtonItem = sender
    popOver?.permittedArrowDirections = .up
    present(popUpViewController, animated: true, completion: nil)
  }
  
}

extension IssueListViewController: UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyle(
    for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }
}
