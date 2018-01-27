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
  let bag = DisposeBag()
  var selectedIssue: Issue!
  var issueIndex: Int!
  var repoIndex: Int!
  let commentList = Variable<[Comment]>([])
  
  init(issue: Issue, issueIndex: Int, repoIndex: Int) {
    self.repoIndex = repoIndex
    self.issueIndex = issueIndex
    selectedIssue = issue
    bindCommentListForIssue(issue: selectedIssue)
    bindOutput()
    
  }
  
  func bindOutput() {
    
  }
  
  //해당이슈의 코멘트 가져오기
  func bindCommentListForIssue(issue: Issue) {
    
    IssueService.fetchComments(issue: issue)
      .asDriver(onErrorJustReturn: [])
      .drive(commentList)
      .disposed(by: bag)
  }
  
  //이슈삭제 api요청 성공하면 로컬 변경하기
  func editIssue(state: IssueService.State, title: String, comment: String, label: [IssueService.Label]) -> Observable<Bool> {
    return APIDataManager.shared.requestEditIssue(title: title, comment: comment, label: [.enhancement], issue: selectedIssue, state: state, repo: LocalDataManager.shared.resultProvider.value[repoIndex])
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
  
  func editComment() {
    
  }
  
  func deleteComment() {
    
  }
  
}
