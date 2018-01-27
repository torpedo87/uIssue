//
//  IssueListViewViewModel.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 20..
//  Copyright © 2018년 samchon. All rights reserved.
//

import RxSwift
import RxCocoa


class IssueListViewViewModel {
  private let bag = DisposeBag()
  
  //input
  var selectedRepo: Repository!
  var repoIndex: Int!
  
  //output
  let issueList = Variable<[Issue]>([])
  
  init(repo: Repository, repoIndex: Int) {
    self.repoIndex = repoIndex
    selectedRepo = repo
    TableViewDataSource.shared.bindIssueList(repo: selectedRepo)
    bindOutput()
    
    issueList.value = TableViewDataSource.shared.sortLocalRepoListByCreated(list: issueList.value) as! [Issue]
  }
  
  func bindOutput() {
    
    TableViewDataSource.shared.issueListProvider
      .asDriver()
      .drive(issueList)
      .disposed(by: bag)
  }
  
}


