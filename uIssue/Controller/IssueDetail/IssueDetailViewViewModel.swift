//
//  IssueDetailViewViewModel.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 23..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation

class IssueDetailViewViewModel {
  
  var selectedIssue: Issue!
  
  init(issue: Issue) {
    selectedIssue = issue
    bindOutput()
  }
  
  func bindOutput() {
    
  }
}
