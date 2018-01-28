//
//  IssueDetailViewViewModel.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 23..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class IssueDetailViewViewModel {
  private let bag = DisposeBag()
  let selectedIssue: Issue!
  private let issueIndex: Int!
  private let repoIndex: Int!
  let issueDetail = Variable<Issue>(Issue())
  
  init(issue: Issue, issueIndex: Int, repoIndex: Int) {
    self.repoIndex = repoIndex
    self.issueIndex = issueIndex
    selectedIssue = issue
    requestFetchComments()
    bindOutput()
    
  }
  
  func bindOutput() {
    LocalDataManager.shared.resultProvider
      .asDriver()
      .map { [weak self] (repoList) -> Repository in
        return repoList[(self?.repoIndex)!]
      }
      .map { Array($0.issuesDic!.values) }
      .map { [weak self] (issueArr) -> Issue in
        return issueArr[(self?.issueIndex)!]
    }.drive(issueDetail)
    .disposed(by: bag)
    
  }
  
  //코멘트 요청 api 성공시 로컬 변경하기
  func requestFetchComments() {
    APIDataManager.shared.requestFetchComment(issue: selectedIssue)
      .asDriver(onErrorJustReturn: [])
      .do(onNext: { [weak self] comments in
        LocalDataManager.shared.changeLocalWhenCommentsFetched(repoIndex: (self?.repoIndex)!, issue: (self?.selectedIssue)!, comments: comments)
      })
      .drive()
      .disposed(by: bag)
  }
  
  //이슈편집 api요청 성공하면 로컬 변경하기
  func editIssue(state: IssueService.State, title: String, comment: String,
                 label: [IssueService.Label]) -> Observable<Bool> {
    return APIDataManager.shared.requestEditIssue(title: title, comment: comment,
                                                  label: [.enhancement], issue: selectedIssue,
                                                  state: state,
                                                  repo: LocalDataManager.shared.resultProvider.value[repoIndex])
      .map({ [weak self] (newIssue) -> Bool in
        if newIssue.id != -1 {
          switch state {
          case .closed: do {
            LocalDataManager.shared.changeLocalWhenIssueClosed(newIssue: newIssue, repoIndex: (self?.repoIndex)!)
            }
          default: do {
            LocalDataManager.shared.changeLocalWhenIssueEdited(newIssue: newIssue, repoIndex: (self?.repoIndex)!)
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
  
  //코멘트 편집 api요청 성공하면 로컬 변경하기
  func editComment() -> Observable<Bool> {
    return Observable.just(false)
  }
  
  func deleteComment() {
    
  }
  
}
