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
  let tempList = Variable<[Issue]>([])
  
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
      .drive(tempList)
      .disposed(by: bag)
    
    tempList.asDriver()
      .map({ (issueArr) -> [Issue] in
        issueArr.filter { $0.state == "open" }
      })
      .drive(issueList)
      .disposed(by: bag)
    
    
    //로컬 레퍼지토리에 asssignee 넣기
    let selectedRepo = LocalDataManager.shared.getRepo(repoId: repoId)
    IssueService().getAssignees(repo: selectedRepo)
      .asDriver(onErrorJustReturn: [])
      .drive(onNext: { users in
        LocalDataManager.shared.setAssigneesDic(repoId: repoId, assignees: users)
      })
      .disposed(by: bag)
  }
  
  func filterByState(state: IssueService.State) {
    if state == .all {
      issueList.value = tempList.value
    } else {
      issueList.value = tempList.value.filter { $0.state == state.rawValue }
    }
  }
  
  func sortBySort(sort: IssueService.Sort) {
    switch sort {
    case .created: issueList.value = issueList.value.sorted(by: { $0.created_at > $1.created_at })
    case .updated: issueList.value = issueList.value.sorted(by: { $0.updated_at > $1.updated_at })
    }
  }
}


