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
  var selectedRepo: RepositoryUI!
  var repoIndex: Int!
  
  //output
  let issueList = Variable<[IssueUI]>([])
  
  init(repo: RepositoryUI, repoIndex: Int) {
    self.repoIndex = repoIndex
    selectedRepo = repo
    TableViewDataSource.shared.bindIssueList(repo: selectedRepo)
    bindOutput()
  }
  
  func bindOutput() {
    
    TableViewDataSource.shared.issueListProvider
      .asDriver()
      .drive(issueList)
      .disposed(by: bag)
  }
  
}


