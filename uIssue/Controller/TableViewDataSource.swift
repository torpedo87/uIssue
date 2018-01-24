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
  var allIssuesProvider = Variable<[Issue]>([])
  var issueListProvider = Variable<[Issue]>([])
  var repoListProvider = Variable<[Repository]>([])
  
  //all issue
  func bindAllIssues(filter: IssueService.Filter, state: IssueService.State, sort: IssueService.Sort) {
    IssueService.fetchAllIssues(filter: filter, state: state, sort: sort)
      .catchErrorJustReturn([])
      .bind(to: allIssuesProvider)
      .disposed(by: bag)
  }
  
  //repoList
  func bindRepoList() {
    allIssuesProvider.asObservable()
      .map { (issues) -> [Repository] in
        issues.map { $0.repository! }.filter { $0.open_issues > 0 }
    }.asDriver(onErrorJustReturn: [])
    .drive(repoListProvider)
    .disposed(by: bag)
  }
  
  //issueList
  func bindIssueList(repo: Repository) {
    allIssuesProvider.asObservable()
      .map { issues in
        issues.filter { $0.repository?.id == repo.id }
    }.asDriver(onErrorJustReturn: [])
    .drive(issueListProvider)
    .disposed(by: bag)
  }
  
  func createIssue(title: String,
                   comment: String,
                   label: [IssueService.Label],
                   repo: Repository) -> Observable<Bool> {
    return IssueService.createIssue(title: title,
                                        comment: comment,
                                        label: label,
                                        repo: repo)
      .do(onNext: { [weak self] (newIssue) in
        self?.allIssuesProvider.value.insert(newIssue, at: 0)
      })
      .map { (issue) -> Bool in
        if issue.title != "" {
          return true
        }
        return false
    }.catchErrorJustReturn(false)
  }

  func editIssue(title: String,
                 comment: String,
                 label: [IssueService.Label],
                 issue: Issue,
                 state: IssueService.State) -> Observable<Bool> {
    return IssueService.editIssue(title: title, comment: comment, label: label, issue: issue, state: state)
      .asObservable()
      .do(onNext: { [weak self] issue in
        switch state {
        case .closed: do {
          self?.allIssuesProvider.value = (self?.allIssuesProvider.value.filter { $0.number != issue.number })!
          }
        case .open: do {
          self?.changeLocalWhenIssueUpdated(issue: issue)
          }
        default: break
        }
      })
      .map { (issue) -> Bool in
        if issue.title != "" {
          return true
        }
        return false
    }.catchErrorJustReturn(false)
  }


  func changeLocalWhenIssueUpdated(issue: Issue) {
    var index: Int = -1
    for i in 0..<allIssuesProvider.value.count {
      if allIssuesProvider.value[i].number == issue.number {
        index = i
      }
    }
    if index != -1 {
      allIssuesProvider.value[index] = issue
    }
  }
  
}
