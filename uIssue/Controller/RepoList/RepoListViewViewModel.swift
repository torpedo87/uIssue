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
  let repoList = Variable<[RepositoryUI]>([])
  
  init() {
    RawDataSource.shared.bindAllIssues(filter: .created, state: .all, sort: .created)
    RawDataSource.shared.getTempRepoUIListFromIssueArr()
    RawDataSource.shared.bindIssueUI()
    RawDataSource.shared.inputIssueUIToRepoUI()
    
    bindOutput()
  }
  
  func bindOutput() {
    TableViewDataSource.shared.resultProvider
      .asDriver()
      .drive(repoList)
      .disposed(by: bag)
    
  }
  
}
