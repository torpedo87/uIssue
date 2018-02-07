//
//  IssuePropertyItem.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 7..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation

struct LabelItem {
  var label: IssueService.Label
  var isChecked: Bool
  
  mutating func setIsChecked(check: Bool) {
    self.isChecked = check
  }
  
  mutating func toggleIsChecked() {
    self.isChecked = !isChecked
  }
}

struct AssigneeItem {
  var user: User
  var isChecked: Bool
  
  mutating func setIsChecked(check: Bool) {
    self.isChecked = check
  }
  
  mutating func toggleIsChecked() {
    self.isChecked = !isChecked
  }
}
