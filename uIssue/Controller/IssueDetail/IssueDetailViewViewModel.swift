//
//  IssueDetailViewViewModel.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 23..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation
import RxSwift

class IssueDetailViewViewModel {
  
  var selectedIssue: Issue!
  
  init(issue: Issue) {
    selectedIssue = issue
    bindOutput()
  }
  
  func bindOutput() {
    
  }
  
  func requestEditIssue(title: String, comment: String, label: [IssueDataManager.Label], state: IssueDataManager.State) -> Observable<Issue> {
    return IssueDataManager.editIssue(title: title, comment: comment, label: label, issue: selectedIssue, state: state)
  }
}
