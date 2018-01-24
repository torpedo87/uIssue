//
//  DataProvider.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 24..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class DataProvider {
  static let shared: DataProvider = DataProvider()
  
  private let bag = DisposeBag()
  var issueListProvider = Variable<[Issue]>([])
  var repoListProvider = Variable<[Repository]>([])
  
  func fetchRepoList() {
    IssueDataManager.fetchRepoList(sort: .created)
      .catchErrorJustReturn([])
      .bind(to: repoListProvider)
      .disposed(by: bag)
  }
  
  func fetchIssueList(repo: Repository, sort: IssueDataManager.Sort, state: IssueDataManager.State) {
    IssueDataManager.fetchIssueListForRepo(repo: repo, sort: sort, state: state)
      .catchErrorJustReturn([])
      .bind(to: issueListProvider)
      .disposed(by: bag)
  }
  
  func createIssue(title: String,
                   comment: String,
                   label: [IssueDataManager.Label],
                   repo: Repository) -> Observable<Bool> {
    return IssueDataManager.createIssue(title: title,
                                        comment: comment,
                                        label: label,
                                        repo: repo)
      .do(onNext: { [weak self] (newIssue) in
        self?.issueListProvider.value.insert(newIssue, at: 0)
      })
      .debug("22222222222222222222222222222")
      .map { (issue) -> Bool in
        if issue.title != "" {
          return true
        }
        return false
    }.catchErrorJustReturn(false)
  }
  
  func editIssue(title: String,
                 comment: String,
                 label: [IssueDataManager.Label],
                 issue: Issue,
                 state: IssueDataManager.State) -> Observable<Bool> {
    return IssueDataManager.editIssue(title: title, comment: comment, label: label, issue: issue, state: state)
      .asObservable()
      .do(onNext: { [weak self] issue in
        if state == .closed { self?.removeLocalIssue(issue: issue) }
        else if state == .open { self?.updateLocalIssueList(issue: issue) }
      })
      .map { (issue) -> Bool in
        if issue.title != "" {
          return true
        }
        return false
    }.catchErrorJustReturn(false)
  }
  
  func updateLocalIssueList(issue: Issue) {
    var index: Int = -1
    for i in 0..<issueListProvider.value.count {
      if issueListProvider.value[i].number == issue.number {
        index = i
      }
    }
    if index != -1 {
      issueListProvider.value[index] = issue
    }
  }
  
  func removeLocalIssue(issue: Issue) {
    issueListProvider.value =
    issueListProvider.value.filter { $0.number != issue.number }
  }
}
