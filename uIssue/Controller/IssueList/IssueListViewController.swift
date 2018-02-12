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
  private let topView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(hex: "F6F8FA")
    return view
  }()

  private let stateButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("STATE ▽", for: UIControlState.normal)
    btn.setTitle("STATE △", for: UIControlState.selected)
    btn.setTitleColor(UIColor.blue, for: UIControlState.normal)
    return btn
  }()
  
  private let sortButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("SORT ▽", for: UIControlState.normal)
    btn.setTitle("SORT △", for: UIControlState.selected)
    btn.setTitleColor(UIColor.blue, for: UIControlState.normal)
    return btn
  }()
  
  private let labelButton: UIButton = {
    let btn = UIButton()
    btn.setTitle("LABEL ▽", for: UIControlState.normal)
    btn.setTitle("LABEL △", for: UIControlState.selected)
    btn.setTitleColor(UIColor.blue, for: UIControlState.normal)
    return btn
  }()
  
  private let tableView: UITableView = {
    let view = UITableView()
    view.register(ListCell.self,
                  forCellReuseIdentifier: ListCell.reuseIdentifier)
    view.rowHeight = 50
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
    view.addSubview(topView)
    topView.addSubview(stateButton)
    topView.addSubview(sortButton)
    topView.addSubview(labelButton)
    view.addSubview(tableView)
    
    topView.snp.makeConstraints { (make) in
      make.top.equalToSuperview().offset(85)
      make.left.right.equalToSuperview()
      make.height.equalTo(50)
    }
    
    stateButton.snp.makeConstraints { (make) in
      stateButton.sizeToFit()
      make.left.top.bottom.equalTo(topView)
    }
    
    sortButton.snp.makeConstraints { (make) in
      sortButton.sizeToFit()
      make.right.top.bottom.equalTo(topView)
    }
    
    labelButton.snp.makeConstraints { (make) in
      labelButton.sizeToFit()
      make.top.bottom.equalTo(topView)
      make.right.equalTo(sortButton.snp.left).offset(-10)
    }
    
    tableView.snp.makeConstraints({ (make) in
      make.left.right.bottom.equalToSuperview()
      make.top.equalTo(topView.snp.bottom)
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
  
  func presentPopUp(sender: UIButton, mode: PopUpViewController.PopUpMode) {
    let popUpViewController =
      PopUpViewController.createWith(viewModel: viewModel, mode: mode)
    popUpViewController.modalPresentationStyle = .popover
    popUpViewController.preferredContentSize = CGSize(width: 100, height: popUpViewController.getTableViewHeight())
    let popOver = popUpViewController.popoverPresentationController
    popOver?.delegate = self
    popOver?.sourceView = sender
    present(popUpViewController, animated: true, completion: nil)
  }
  
}

extension IssueListViewController: UIPopoverPresentationControllerDelegate {
  func adaptivePresentationStyle(
    for controller: UIPresentationController) -> UIModalPresentationStyle {
    return .none
  }
}
