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
  let selectedRepo: Repository!
  let repoIndex: Int!
  
  //output
  let issueList = Variable<[Issue]>([])
  
  init(repo: Repository, repoIndex: Int) {
    self.repoIndex = repoIndex
    selectedRepo = repo
    bindOutput()
  }
  
  func bindOutput() {
    
    LocalDataManager.shared.getProvider()
      .asDriver(onErrorJustReturn: [])
      .map { [weak self] (repoList) in
        repoList.filter { $0.id == self?.selectedRepo.id }
      }.map { $0.first! }
      .map { Array($0.issuesDic!.values) }
      .map({ (issueArr) -> [Issue] in
        return issueArr.sorted(by: { $0.created_at > $1.created_at })
      })
      .drive(issueList)
      .disposed(by: bag)
  }
  
  
  
}


