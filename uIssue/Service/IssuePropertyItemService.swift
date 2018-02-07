//
//  IssuePropertyItemService.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 7..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation

class IssuePropertyItemService {
  
  func changeLabelArrToDict(arr: [IssueService.Label]) -> [String:LabelItem] {
    var dict = [String:LabelItem]()
    for label in arr {
      dict[label.rawValue] = LabelItem(label: label, isChecked: false)
    }
    return dict
  }
  
  func changeAssigneeArrToDict(arr: [User]) -> [String:AssigneeItem] {
    var dict = [String:AssigneeItem]()
    for user in arr {
      dict[user.login] = AssigneeItem(user: user, isChecked: false)
    }
    return dict
  }
  
  
  
  func transformLabelToItem(labels: [IssueService.Label]) -> [LabelItem] {
    var items = [LabelItem]()
    for label in labels {
      let item = LabelItem(label: label, isChecked: false)
      items.append(item)
    }
    return items
  }
  
  func transformUserToItem(users: [User]) -> [AssigneeItem] {
    var items = [AssigneeItem]()
    for user in users {
      let item = AssigneeItem(user: user, isChecked: false)
      items.append(item)
    }
    return items
  }
  
  
}
