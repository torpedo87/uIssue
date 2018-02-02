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
  let repoId: Int!
  
  //output
  let issueList = Variable<[Issue]>([])
  
  init(repoId: Int) {
    self.repoId = repoId
    bindOutput(repoId: repoId)
  }
  
  func bindOutput(repoId: Int) {
    LocalDataManager.shared.getProvider()
      .asDriver(onErrorJustReturn: [Int : Repository]())
      .map { $0.filter { $0.value.issuesDic!.count > 0 } }
      .map({ (repoDict) -> [Issue] in
        if let issueDic = repoDict[repoId]?.issuesDic {
          return Array(issueDic.values).sorted(by: { $0.created_at > $1.created_at })
        }
        return []
      })
      .drive(issueList)
      .disposed(by: bag)
  }
  
  func sortIssueListByCreated() {
    issueList.value = issueList.value.sorted(by: { $0.created_at > $1.created_at })
  }
  
}


