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
  var resultProvider = Variable<[Repository]>([])
  var issueListProvider = Variable<[Issue]>([])
  
  
  //해당 레퍼지토리의 이슈리스트 바인딩
  func bindIssueList(repo: Repository) {
    
    resultProvider.asDriver()
      .map { (repoList) in
        repoList.filter { $0.id == repo.id }
      }.map { $0.first! }
      .map { $0.issueArr! }
      .drive(issueListProvider)
      .disposed(by: bag)
  }
  
  func createIssue(title: String, comment: String, repoIndex: Int) -> Observable<Bool> {
    return RawDataSource.shared.requestCreateIssue(title: title, comment: comment, label: [.enhancement], repo: resultProvider.value[repoIndex])
      .map({ [weak self] (newIssue) -> Bool in
        if newIssue.id != -1 {
          self?.resultProvider.value[repoIndex].issueArr?.append(newIssue)
          return true
        }
        return false
      })
    
  }
  
  func editIssue(issue: Issue, issueIndex: Int, state: IssueService.State, title: String, comment: String) -> Observable<Bool> {
    return RawDataSource.shared.requestEditIssue(title: title, comment: comment, label: [.enhancement], issue: issue, state: state)
      .do(onNext: { [weak self] success in
        if success {
          switch state {
          case .closed: do {
            var repoIndex: Int = -1
            for i in 0..<(self?.resultProvider.value.count)! {
              if self?.resultProvider.value[i].id == issue.repository?.id {
                repoIndex = i
              }
            }
            if repoIndex != -1 {
              self?.resultProvider.value[repoIndex].issueArr?.remove(at: issueIndex)
            }
            }
          default: do {
            var repoIndex: Int = -1
            for i in 0..<(self?.resultProvider.value.count)! {
              if self?.resultProvider.value[i].id == issue.repository?.id {
                repoIndex = i
              }
            }
            if repoIndex != -1 {
              self?.resultProvider.value[repoIndex].issueArr![issueIndex] = issue
            }
            }
          }
          
        }
      })
    
  }
  
}
