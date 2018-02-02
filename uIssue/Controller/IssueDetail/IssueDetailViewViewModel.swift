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
  private let issueId: Int!
  private let repoId: Int!
  let issueDetail = Variable<Issue>(Issue())
  private let commentList = Variable<[Comment]>([])
  private let issueApi: IssueServiceRepresentable
  
  init(repoId: Int, issueId: Int, issueApi: IssueServiceRepresentable = IssueService()) {
    self.issueApi = issueApi
    self.repoId = repoId
    self.issueId = issueId
    self.selectedIssue = LocalDataManager.shared.getRepo(repoId: repoId).issuesDic![issueId]
    
    bindOutput(repoId: repoId, issueId: issueId)
  }
  
  func bindOutput(repoId: Int, issueId: Int) {
    LocalDataManager.shared.getProvider()
      .asDriver(onErrorJustReturn: [Int : Repository]())
      .map { $0.filter { $0.value.issuesDic!.count > 0 } }
      .map({ (repoDict) -> Issue in
        if let _ = repoDict[repoId]?.issuesDic![issueId] {
          return (repoDict[repoId]?.issuesDic![issueId])!
        } else {
          return Issue()
        }
      })
    .drive(issueDetail)
    .disposed(by: bag)
  }
  
  //코멘트 요청 api 성공시 로컬 변경하기
  func requestFetchComments() {
    issueApi.fetchComments(issue: selectedIssue)
      .asDriver(onErrorJustReturn: [])
      .drive(onNext: { [weak self] (comments) in
        LocalDataManager.shared.fetchComments(repoId: (self?.repoId)!, issue: (self?.selectedIssue)!, comments: comments)
      })
      .disposed(by: bag)
  }
  
  //이슈편집 api요청 성공하면 로컬 변경하기
  func editIssue(state: IssueService.State, newTitleText: String, newCommentText: String,
                 label: [IssueService.Label]) -> Observable<Bool> {
    let selectedRepo = LocalDataManager.shared.getRepo(repoId: self.repoId)
    
    return issueApi.editIssue(title: newTitleText, comment: newCommentText,
                                                  label: [.enhancement], issue: selectedIssue,
                                                  state: state,
                                                  repo: selectedRepo)
      .map({ [weak self] (editedIssue) -> Bool in
        if editedIssue.id != -1 {
          switch state {
          case .closed: do {
            LocalDataManager.shared.closeIssue(repoId: (self?.repoId)!, existingIssue: editedIssue)
            }
          default: do {
            LocalDataManager.shared.editIssue(repoId: (self?.repoId)!, newIssue: editedIssue)
            }
          }
          return true
        } else {
          return false
        }
      })
    
  }
  
  //코멘트 생성 api 요청 성공시 로컬 변경하기
  func createComment(newCommentBody: String) -> Observable<Bool> {
    let repoId = self.repoId!
    let selectedIssue = self.selectedIssue!
    
    return issueApi.createComment(issue: selectedIssue, commentBody: newCommentBody)
      .map({ (newComment) -> Bool in
        if newComment.id != -1 {
          LocalDataManager.shared.createComment(repoId: repoId, issue: selectedIssue, newComment: newComment)
          return true
        }
        return false
      })
  }
  
  //코멘트 편집 api요청 성공하면 로컬 변경하기
  func editComment(existingComment: Comment, newCommentText: String) -> Observable<Bool> {
    let selectedIssue = self.selectedIssue!
    let repoId = self.repoId!
    
    return issueApi.editComment(issue: selectedIssue, comment: existingComment, newCommentText: newCommentText)
      .map({ (newComment) -> Bool in
        if newComment.id != -1 {
          LocalDataManager.shared.editComment(repoId: repoId, issue: selectedIssue, newComment: newComment)
          return true
        } else {
          return false
        }
      })
  }
  
  func deleteComment(existingComment: Comment) -> Observable<Bool> {
    let selectedIssue = self.selectedIssue!
    let repoId = self.repoId!
    
    return issueApi.deleteComment(issue: selectedIssue, comment: existingComment)
      .map({ (success) -> Bool in
        if success {
          LocalDataManager.shared.deleteComment(repoId: repoId, issue: selectedIssue, existingComment: existingComment)
          return true
        } else {
          return false
        }
      })
  }
  
  func cancelEditIssue() {
    LocalDataManager.shared.editIssue(repoId: repoId, newIssue: selectedIssue)
  }
  
  func cancelEditComment(existingComment: Comment) {
    LocalDataManager.shared.editComment(repoId: repoId, issue: selectedIssue, newComment: existingComment)
  }
}
