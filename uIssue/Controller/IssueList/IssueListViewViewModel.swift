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
    bindOutput()
    
  }
  
  func bindOutput() {
    
    LocalDataManager.shared.resultProvider
      .asDriver()
      .map { [weak self] (repoList) in
        repoList.filter { $0.id == self?.selectedRepo.id }
      }.map { $0.first! }
      .map { Array($0.issuesDic!.values) }
      .drive(issueList)
      .disposed(by: bag)
  }
  
}


