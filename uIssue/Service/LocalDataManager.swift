//
//  LocalDataManager.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 24..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LocalDataManager {
  static let shared: LocalDataManager = LocalDataManager()
  private let bag = DisposeBag()
  
  //local
  let resultProvider = Variable<[Repository]>([])
  
  
  func changeLocalWhenIssueCreated(newIssue: Issue, repoIndex: Int) {
    resultProvider.value[repoIndex].issuesDic![newIssue.id] = newIssue
  }
  
  func changeLocalWhenIssueClosed(newIssue: Issue, repoIndex: Int) {
    resultProvider.value[repoIndex].issuesDic?.removeValue(forKey: newIssue.id)
  }
  
  func changeLocalWhenIssueEdited(newIssue: Issue, repoIndex: Int) {
    resultProvider.value[repoIndex].issuesDic?.updateValue(newIssue, forKey: newIssue.id)
  }
  
  func changeLocalWhenCommentsFetched(repoIndex: Int, issue: Issue, comments: [Comment]) {
    resultProvider.value[repoIndex].issuesDic![issue.id]?.setCommentsDic(comments: comments)
  }
}
