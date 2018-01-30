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
  let repoIndex: Int!
  let issueDetail = Variable<Issue>(Issue())
  let apiType: IssueServiceRepresentable.Type
  
  init(issue: Issue, issueIndex: Int, repoIndex: Int, apiType: IssueServiceRepresentable.Type = IssueService.self) {
    self.apiType = apiType
    self.repoIndex = repoIndex
    self.issueIndex = issueIndex
    selectedIssue = issue
    requestFetchComments()
    bindOutput()
    
  }
  
  func bindOutput() {
    LocalDataManager.shared.provider()
      .asDriver(onErrorJustReturn: [])
      .map { [weak self] (repoList) -> Repository in
        return repoList[(self?.repoIndex)!]
      }
      .map { Array($0.issuesDic!.values) }
      .map({ (issueArr) -> [Issue] in
        return issueArr.sorted(by: { $0.created_at > $1.created_at })
      })
      .map { [weak self] (issueArr) -> Issue in
        return issueArr[(self?.issueIndex)!]
    }.drive(issueDetail)
    .disposed(by: bag)
    
  }
  
  //코멘트 요청 api 성공시 로컬 변경하기
  func requestFetchComments() {
    apiType.fetchComments(issue: selectedIssue)
      .asDriver(onErrorJustReturn: [])
      .drive(onNext: { [weak self] (comments) in
        LocalDataManager.shared.fetchComments(repoIndex: (self?.repoIndex)!, issue: (self?.selectedIssue)!, comments: comments)
      })
      .disposed(by: bag)
  }
  
  //이슈편집 api요청 성공하면 로컬 변경하기
  func editIssue(state: IssueService.State, newTitleText: String, newCommentText: String,
                 label: [IssueService.Label]) -> Observable<Bool> {
    
    return apiType.editIssue(title: newTitleText, comment: newCommentText,
                                                  label: [.enhancement], issue: selectedIssue,
                                                  state: state,
                                                  repo: LocalDataManager.shared.getRepo(index: repoIndex))
      .map({ [weak self] (newIssue) -> Bool in
        if newIssue.id != -1 {
          switch state {
          case .closed: do {
            LocalDataManager.shared.closeIssue(newIssue: newIssue, repoIndex: (self?.repoIndex)!)
            }
          default: do {
            LocalDataManager.shared.editIssue(newIssue: newIssue, repoIndex: (self?.repoIndex)!)
            }
          }
          return true
        } else {
          return false
        }
      })
    
  }
  
  //코멘트 생성 api 요청 성공시 로컬 변경하기
  func createComment(issue: Issue, newCommentBody: String, repoIndex: Int) -> Observable<Bool> {
    
    return apiType.createComment(issue: issue, commentBody: newCommentBody)
      .map({ (newComment) -> Bool in
        if newComment.id != -1 {
          LocalDataManager.shared.createComment(repoIndex: repoIndex, issue: issue, newComment: newComment)
          return true
        }
        return false
      })
  }
  
  //코멘트 편집 api요청 성공하면 로컬 변경하기
  func editComment(issue: Issue, existingComment: Comment, repoIndex: Int, newCommentText: String) -> Observable<Bool> {
    return apiType.editComment(issue: issue, comment: existingComment, newCommentText: newCommentText)
      .map({ (newComment) -> Bool in
        if newComment.id != -1 {
          LocalDataManager.shared.editComment(repoIndex: repoIndex, issue: issue, newComment: newComment)
          return true
        } else {
          return false
        }
      })
  }
  
  func deleteComment(issue: Issue, existingComment: Comment, repoIndex: Int) -> Observable<Bool> {
    return apiType.deleteComment(issue: issue, comment: existingComment)
      .map({ (success) -> Bool in
        if success {
          LocalDataManager.shared.deleteComment(repoIndex: repoIndex, issue: issue, existingComment: existingComment)
          return true
        } else {
          return false
        }
      })
  }
  
}
