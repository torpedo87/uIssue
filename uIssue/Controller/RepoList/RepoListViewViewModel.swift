//
//  RepoListViewViewModel.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 20..
//  Copyright © 2018년 samchon. All rights reserved.
//

import RxSwift
import RxCocoa


class RepoListViewViewModel {
  private let bag = DisposeBag()
  
  //output
  let repoList = Variable<[Repository]>([])
  
  init() {
    RawDataSource.shared.bindAllIssues(filter: .created, state: .all, sort: .created)
    RawDataSource.shared.getTempRepoUIListFromIssueArr()
    RawDataSource.shared.inputIssueToRepo()
    
    bindOutput()
    
    repoList.value = TableViewDataSource.shared.sortLocalRepoListByCreated(list: repoList.value) as! [Repository]
  }
  
  func bindOutput() {
    TableViewDataSource.shared.resultProvider
      .asDriver()
      .drive(repoList)
      .disposed(by: bag)
    
  }
  
}
