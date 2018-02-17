//
//  IssuePropertyItem.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 7..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation

protocol Checkable {
  var isChecked: Bool { get set }
  
  mutating func setIsChecked(check: Bool)
}

extension Checkable {
  mutating func setIsChecked(check: Bool) {
    self.isChecked = check
  }
}

struct LabelItem: Checkable {
  var label: IssueService.Label
  var isChecked: Bool
}

struct AssigneeItem: Checkable {
  var user: User
  var isChecked: Bool
}
