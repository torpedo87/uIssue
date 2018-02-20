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
  
  //mode 설정시 list 채워짐
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
  
  private let tableView: UITableView = {
    let view = UITableView()
    view.register(ListCell.self,
                  forCellReuseIdentifier: ListCell.reuseIdentifier)
    view.rowHeight = UIScreen.main.bounds.height / 20
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
      make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
      make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
      make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
    }
    
  }
  
  func bindTableView() {
    list.asDriver()
      .drive(onNext: { [unowned self] _ in self.tableView.reloadData() })
      .disposed(by: bag)
    
    //datasource
    list.asObservable()
      .bind(to: tableView.rx.items) {
        [unowned self] (tableView: UITableView, index: Int, element: String) in
        let cell =
          ListCell(style: .default, reuseIdentifier: ListCell.reuseIdentifier)
        cell.configureCell(list: self.list.value, index: index)
        return cell
      }
      .disposed(by: bag)
    
    //delegate
    tableView.rx
      .itemSelected
      .subscribe(onNext: { [unowned self] indexPath in
        switch self.popUpMode! {
        case .state:
          self.tableView.allowsMultipleSelection = false
          self.viewModel.filterByState(state: IssueService.State.arr[indexPath.row])
        case .sort:
          self.tableView.allowsMultipleSelection = false
          self.viewModel.sortBySort(sort: IssueService.Sort.arr[indexPath.row])
        case .label:
          self.tableView.allowsMultipleSelection = true
          var selectedLabels = [IssueService.Label]()
          if let selectedIndexPaths = self.tableView.indexPathsForSelectedRows {
            for indexpath in selectedIndexPaths {
              selectedLabels.append(IssueService.Label.arr[indexpath.row])
            }
          }
          self.viewModel.filterByLabels(labels: selectedLabels)
        }
      })
      .disposed(by: bag)
    
    tableView.rx
      .itemDeselected
      .subscribe(onNext: { [unowned self] indexPath in
        switch self.popUpMode! {
        case .label:
          self.tableView.allowsMultipleSelection = true
          var selectedLabels = [IssueService.Label]()
          if let selectedIndexPaths = self.tableView.indexPathsForSelectedRows {
            for indexpath in selectedIndexPaths {
              selectedLabels.append(IssueService.Label.arr[indexpath.row])
            }
          }
          self.viewModel.filterByLabels(labels: selectedLabels)
        default: break
        }
      })
      .disposed(by: bag)
  }
  
  func getTableViewHeight() -> CGFloat {
    return tableView.rowHeight * CGFloat(list.value.count)
  }
}
