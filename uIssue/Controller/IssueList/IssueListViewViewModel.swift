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
  let rawIssueList = BehaviorRelay<[Issue]>(value: [])
  let issueList = BehaviorRelay<[Issue]>(value: [])
  
  init(repoId: Int) {
    self.repoId = repoId
    bindOutput(repoId: repoId)
  }
  
  func bindOutput(repoId: Int) {
    
    //로컬로부터 해당 레퍼지토리의 모든 이슈 가져오기
    LocalDataManager.shared.getProvider()
      .asDriver(onErrorJustReturn: [Int : Repository]())
      .map { $0.filter { $0.value.issuesDic!.count > 0 } }
      .map({ (repoDict) -> [Issue] in
        if let issueDic = repoDict[repoId]?.issuesDic {
          return Array(issueDic.values)
            .sorted(by: { $0.created_at > $1.created_at })
        }
        return []
      })
      .drive(rawIssueList)
      .disposed(by: bag)
    
    //오픈 이슈만 걸러내기
    rawIssueList.asDriver()
      .map({ (issueArr) -> [Issue] in
        issueArr.filter { $0.state == "open" }
      })
      .drive(issueList)
      .disposed(by: bag)
    
    
    //로컬 레퍼지토리에 asssignee 넣기
    let selectedRepo =
      LocalDataManager.shared.getRepo(repoId: repoId)
    IssueService().getAssignees(repo: selectedRepo)
      .asDriver(onErrorJustReturn: [])
      .drive(onNext: { users in
        LocalDataManager.shared.setAssigneesDic(repoId: repoId,
                                                assignees: users)
      })
      .disposed(by: bag)
  }
  
  //필터링
  func filterByState(state: IssueService.State) {
    if state == .all {
      issueList.accept(rawIssueList.value)
    } else {
      issueList.accept(rawIssueList.value.filter { $0.state == state.rawValue })
    }
  }
  
  //정렬
  func sortBySort(sort: IssueService.Sort) {
    switch sort {
    case .created:
      issueList.accept(issueList.value.sorted(by: { $0.created_at > $1.created_at }))
      
    case .updated:
      issueList.accept(issueList.value.sorted(by: { $0.updated_at > $1.updated_at }))
    }
  }
  
  //라벨
  func filterByLabels(labels: [IssueService.Label]) {
    issueList.accept(rawIssueList.value.filter { $0.state == "open" })
    var issueLabels = [IssueLabel]()
    for label in labels {
      issueLabels.append(IssueLabel(name: label.rawValue))
    }
    let issueLabelSet = Set(issueLabels)
    issueList.accept(issueList.value.filter {
      issueLabelSet.isSubset(of: Set($0.labels))
    })
  }
}


