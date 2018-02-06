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

class IssueDetailViewViewModel: PropertySettable {
  
  private let bag = DisposeBag()
  private let issueId: Int!
  private let repoId: Int!
  let issueDetail = Variable<Issue>(Issue())
  let commentList = Variable<[Comment]>([])
  private let issueApi: IssueServiceRepresentable
  let labelItems = Variable<[LabelItem]>(IssueService().transformLabelToItem(labels: IssueService.Label.arr))
  let assigneeItems = Variable<[AssigneeItem]>([])
  
  init(repoId: Int, issueId: Int, issueApi: IssueServiceRepresentable = IssueService()) {
    self.issueApi = issueApi
    self.repoId = repoId
    self.issueId = issueId
    
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
    
    issueDetail.asDriver()
      .map { (issue) -> [Comment] in
        if let _ = issue.commentsDic {
          return Array(issue.commentsDic!.values).sorted(by: { $0.created_at < $1.created_at })
        }
        return []
    }.drive(commentList)
    .disposed(by: bag)
    
    //레퍼지토리 사용자 가져오기
    issueApi.getAssignees(repo: LocalDataManager.shared.getRepo(repoId: repoId))
      .map({ (users) -> [AssigneeItem] in
        return IssueService().transformUserToItem(users: users)
      })
      .asDriver(onErrorJustReturn: [])
      .drive(assigneeItems)
      .disposed(by: bag)
    
    //이슈의 라벨, 사용자 체크
    issueDetail.asDriver()
      .drive(onNext: { [weak self] issue in
        let issueLabels = issue.labels
        let assignees = issue.assignees
        let labels = IssueService().transformIssueLabelToLabel(issueLabelArr: issueLabels)
        for label in labels {
          self?.labelItems.value = IssueService().checkLabel(label: label, items: (self?.labelItems.value)!, check: true)
        }
        
        for assignee in assignees {
          self?.assigneeItems.value = IssueService().checkUser(user: assignee, items: (self?.assigneeItems.value)!, check: true)
        } 
        
      }).disposed(by: bag)
  }
  
  //코멘트 요청 api 성공시 로컬 변경하기
  func requestFetchComments() {
    issueApi.fetchComments(issue: issueDetail.value)
      .asDriver(onErrorJustReturn: [])
      .drive(onNext: { [weak self] (comments) in
        LocalDataManager.shared.fetchComments(repoId: (self?.repoId)!, issue: (self?.issueDetail.value)!, comments: comments)
      })
      .disposed(by: bag)
  }
  
  //이슈편집 api요청 성공하면 로컬 변경하기
  func editIssue(state: IssueService.State, newTitleText: String, newBodyText: String,
                 label: [IssueService.Label]) -> Observable<Bool> {
    let selectedRepo = LocalDataManager.shared.getRepo(repoId: self.repoId)
    
    return issueApi.editIssue(title: newTitleText, body: newBodyText,
                              label: label, issue: issueDetail.value,
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
    let selectedIssue = issueDetail.value
    
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
    let selectedIssue = issueDetail.value
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
    let selectedIssue = issueDetail.value
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
}
