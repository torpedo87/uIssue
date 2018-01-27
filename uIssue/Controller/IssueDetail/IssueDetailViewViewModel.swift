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
    TableViewDataSource.shared.bindCommentListForIssue(issue: issue)
    bindOutput()
    
    commentList.value = TableViewDataSource.shared.sortLocalRepoListByCreated(list: commentList.value) as! [Comment]
  }
  
  func bindOutput() {
    TableViewDataSource.shared.commentsListForIssueProvier.asDriver()
      .drive(commentList)
      .disposed(by: bag)
  }
  
  func requestEditIssue(title: String, comment: String, label: [IssueService.Label], state: IssueService.State) -> Observable<Bool> {
    return TableViewDataSource.shared.editIssue(issue: selectedIssue, issueIndex: issueIndex, state: state, title: title, comment: comment, repoIndex: repoIndex)
  }
  
}
