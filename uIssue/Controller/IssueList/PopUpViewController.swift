//
//  PopUpViewController.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 4..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PopUpViewController: UIViewController {
  
  enum PopUpMode {
    case sort
    case state
    case label
  }
  
  private var popUpMode: PopUpMode! {
    didSet {
      switch popUpMode! {
      case .sort: do {
        list = BehaviorRelay<[String]>(value: IssueService.Sort.arr.map{ $0.rawValue })
        }
      case .state: do {
        list = BehaviorRelay<[String]>(value: IssueService.State.arr.map{ $0.rawValue })
        }
      case .label: do {
        list = BehaviorRelay<[String]>(value: IssueService.Label.arr.map{ $0.rawValue })
        }
      }
    }
  }
  
  private let bag = DisposeBag()
  private var viewModel: IssueListViewViewModel!
  private var list: BehaviorRelay<[String]>!
  
  private lazy var tableView: UITableView = {
    let view = UITableView()
    view.register(ListCell.self,
                  forCellReuseIdentifier: ListCell.reuseIdentifier)
    view.rowHeight = 50
    return view
  }()
  
  static func createWith(viewModel: IssueListViewViewModel,
                         mode: PopUpMode) -> PopUpViewController {
    return {
      $0.viewModel = viewModel
      $0.popUpMode = mode
      return $0
      }(PopUpViewController())
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    bindTableView()
  }
  
  func setupView() {
    view.addSubview(tableView)
    
    tableView.snp.makeConstraints { (make) in
      make.edges.equalTo(view)
    }
    
  }
  
  func bindTableView() {
    list.asDriver()
      .drive(onNext: { [weak self] _ in self?.tableView.reloadData() })
      .disposed(by: bag)
    
    //datasource
    list.asObservable()
      .bind(to: tableView.rx.items) {
        [weak self] (tableView: UITableView, index: Int, element: String) in
        let cell =
          ListCell(style: .default, reuseIdentifier: ListCell.reuseIdentifier)
        cell.configureCell(list: (self?.list.value)!, index: index)
        return cell
      }
      .disposed(by: bag)
    
    //delegate
    tableView.rx
      .itemSelected
      .subscribe(onNext: { [weak self] indexPath in
        self?.tableView.deselectRow(at: indexPath, animated: true)
        switch (self?.popUpMode)! {
        case .state:
          self?.viewModel.filterByState(state: IssueService.State.arr[indexPath.row])
        case .sort:
          self?.viewModel.sortBySort(sort: IssueService.Sort.arr[indexPath.row])
        case .label:
          self?.viewModel.filterByState(state: IssueService.State.arr[indexPath.row])
        }
        self?.dismiss(animated: true, completion: nil)
      })
      .disposed(by: bag)
  }
}
