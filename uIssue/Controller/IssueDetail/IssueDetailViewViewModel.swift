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
  
  var selectedIssue: IssueUI!
  var issueIndex: Int!
  
  init(issue: IssueUI, issueIndex: Int) {
    self.issueIndex = issueIndex
    selectedIssue = issue
    bindOutput()
  }
  
  func bindOutput() {
    
  }
  
  func requestEditIssue(title: String, comment: String, label: [IssueService.Label], state: IssueService.State) {
    
  }
  
  func requestRemoveIssue() {
    TableViewDataSource.shared.deleteLocalIssue(issue: selectedIssue, issueIndex: issueIndex)
  }
}
