//
//  TableViewDataSource.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 24..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TableViewDataSource {
  static let shared: TableViewDataSource = TableViewDataSource()
  private let bag = DisposeBag()
  
  //local
  var resultProvider = Variable<[RepositoryUI]>([])
  var issueListProvider = Variable<[IssueUI]>([])
  
  
  //해당 레퍼지토리의 이슈리스트 바인딩
  func bindIssueList(repo: RepositoryUI) {
    
    resultProvider.asDriver()
      .map { (repoUIList) in
        repoUIList.filter { $0.id == repo.id }
      }.map { $0.first! }
      .map { $0.issueArr! }
      .drive(issueListProvider)
      .disposed(by: bag)
  }
  
  func createLocalIssue(issue: IssueUI, repoIndex: Int) {
    resultProvider.value[repoIndex].issueArr?.append(issue)
  }
  
  func deleteLocalIssue(issue: IssueUI, issueIndex: Int) {
    var repoIndex: Int = -1
    for i in 0..<resultProvider.value.count {
      if resultProvider.value[i].id == issue.repoId {
        repoIndex = i
      }
    }
    if repoIndex != -1 {
      resultProvider.value[repoIndex].issueArr?.remove(at: issueIndex)
    }
  }
  
  func editLocalIssue(issue: IssueUI, issueIndex: Int) {
    var repoIndex: Int = -1
    for i in 0..<resultProvider.value.count {
      if resultProvider.value[i].id == issue.repoId {
        repoIndex = i
      }
    }
    if repoIndex != -1 {
      resultProvider.value[repoIndex].issueArr![issueIndex] = issue
    }
  }
  
}
