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
  var commentsListForIssueProvier = Variable<[Comment]>([])
  
  //해당 레퍼지토리의 이슈리스트 바인딩
  func bindIssueList(repo: Repository) {
    
    resultProvider.asDriver()
      .map { (repoList) in
        repoList.filter { $0.id == repo.id }
      }.map { $0.first! }
      .map { Array($0.issuesDic!.values) }
      .drive(issueListProvider)
      .disposed(by: bag)
  }
  
  //해당이슈의 코멘트 가져오기
  func bindCommentListForIssue(issue: Issue) {
    
    IssueService.fetchComments(issue: issue)
      .asDriver(onErrorJustReturn: [])
      .drive(commentsListForIssueProvier)
      .disposed(by: bag)
    
  }
  
  func sortLocalRepoListByCreated(list: [Sortable]) -> [Sortable] {
    return list.sorted(by: { $0.created_at.compare($1.created_at) == .orderedDescending })
  }
  
  func createIssue(title: String, comment: String, repoIndex: Int) -> Observable<Bool> {
    return RawDataSource.shared.requestCreateIssue(title: title, comment: comment, label: [.enhancement], repo: resultProvider.value[repoIndex])
      .map({ (newIssue) -> Bool in
        if newIssue.id != -1 {
          self.resultProvider.value[repoIndex].issuesDic![newIssue.id] = newIssue
          return true
        }
        return false
      })
  }
  
  func editIssue(issue: Issue, issueIndex: Int, state: IssueService.State, title: String, comment: String, repoIndex: Int) -> Observable<Bool> {
    return RawDataSource.shared.requestEditIssue(title: title, comment: comment, label: [.enhancement], issue: issue, state: state, repo: resultProvider.value[repoIndex])
      .map({ [weak self] (newIssue) -> Bool in
        if newIssue.id != -1 {
          switch state {
          case .closed: do {
            self?.resultProvider.value[repoIndex].issuesDic?.removeValue(forKey: newIssue.id)
            }
          default: do {
            self?.resultProvider.value[repoIndex].issuesDic?.updateValue(newIssue, forKey: newIssue.id)
            }
          }
          return true
        } else {
          return false
        }
      })
    
  }
  
  func createComment() {
    
  }
  
  func editComment() {
    
  }
  
  func deleteComment() {
    
  }
  
}
