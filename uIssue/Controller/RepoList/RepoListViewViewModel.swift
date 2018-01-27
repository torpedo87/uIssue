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
    APIDataManager.shared.bindAllIssues(filter: .created, state: .all, sort: .created)
    APIDataManager.shared.getTempRepoUIListFromIssueArr()
    APIDataManager.shared.inputIssueToRepo()
    
    bindOutput()
  }
  
  func bindOutput() {
    LocalDataManager.shared.resultProvider
      .asDriver()
      .drive(repoList)
      .disposed(by: bag)
    
  }
  
}
