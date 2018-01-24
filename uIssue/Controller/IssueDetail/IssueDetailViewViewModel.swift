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
  
  func requestEditIssue(title: String, comment: String, label: [IssueService.Label], state: IssueService.State) -> Observable<Bool> {
    return TableViewDataSource.shared.editIssue(title: title, comment: comment, label: label, issue: selectedIssue, state: state)
  }
}
