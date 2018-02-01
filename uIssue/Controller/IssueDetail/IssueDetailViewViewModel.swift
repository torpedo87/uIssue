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
  let commentList = Variable<[Comment]>([])
  let issueApi: IssueServiceRepresentable
  
  init(issue: Issue, issueIndex: Int, repoIndex: Int, issueApi: IssueServiceRepresentable = IssueService()) {
    self.issueApi = issueApi
    self.repoIndex = repoIndex
    self.issueIndex = issueIndex
    selectedIssue = issue
    
    bindOutput()
  }
  
  func bindOutput() {
    LocalDataManager.shared.getProvider()
      .asDriver(onErrorJustReturn: [])
      .map { [weak self] (repoList) -> Repository in
        return repoList[(self?.repoIndex)!]
      }
      .map({ (repo) -> [Issue] in
        if let issueDic = repo.issuesDic {
          return Array(issueDic.values)
        }
        return [Issue]()
      })
      .map({ (issueArr) -> [Issue] in
        return issueArr.sorted(by: { $0.created_at > $1.created_at })
      })
      .map { [weak self] (issueArr) -> Issue in
        if issueArr != [] {
          return issueArr[(self?.issueIndex)!]
        }
        return Issue()
    }.drive(issueDetail)
    .disposed(by: bag)
  }
  
  //코멘트 요청 api 성공시 로컬 변경하기
  func requestFetchComments() {
    issueApi.fetchComments(issue: selectedIssue)
      .asDriver(onErrorJustReturn: [])
      .drive(onNext: { [weak self] (comments) in
        LocalDataManager.shared.fetchComments(repoIndex: (self?.repoIndex)!, issue: (self?.selectedIssue)!, comments: comments)
      })
      .disposed(by: bag)
  }
  
  //이슈편집 api요청 성공하면 로컬 변경하기
  func editIssue(state: IssueService.State, newTitleText: String, newCommentText: String,
                 label: [IssueService.Label]) -> Observable<Bool> {
    
    return issueApi.editIssue(title: newTitleText, comment: newCommentText,
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
    
    return issueApi.createComment(issue: issue, commentBody: newCommentBody)
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
    return issueApi.editComment(issue: issue, comment: existingComment, newCommentText: newCommentText)
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
    return issueApi.deleteComment(issue: issue, comment: existingComment)
      .map({ (success) -> Bool in
        if success {
          LocalDataManager.shared.deleteComment(repoIndex: repoIndex, issue: issue, existingComment: existingComment)
          return true
        } else {
          return false
        }
      })
  }
  
  func cancelEditIssue() {
    LocalDataManager.shared.editIssue(newIssue: selectedIssue, repoIndex: repoIndex)
  }
  
  func cancelEditComment(newComment: Comment) {
    LocalDataManager.shared.editComment(repoIndex: repoIndex, issue: selectedIssue, newComment: newComment)
  }
}
