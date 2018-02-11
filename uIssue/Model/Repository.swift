//
//  Repository.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 10..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation

struct Repository: Codable {
  let id: Int
  let name: String
  let owner: User
  let open_issues: Int
  let created_at: String
  var issuesDic: [Int:Issue]?
  var assigneesDic: [Int:User]?
  
  mutating func setIssuesDic(issueArr: [Issue]) {
    self.issuesDic = [Int:Issue]()
    for issue in issueArr {
      self.issuesDic![issue.id] = issue
    }
  }
  
  mutating func setassigneesDic(userArr: [User]) {
    self.assigneesDic = [Int:User]()
    for user in userArr {
      self.assigneesDic![user.id] = user
    }
  }
  
  static let test = Repository(id: 1, name: "name", owner: User.test,
                               open_issues: 1, created_at: "1", issuesDic: nil,
                               assigneesDic: nil)
}

//set 적용을 위해
extension Repository: Equatable {
  static func ==(lhs: Repository, rhs: Repository) -> Bool {
    return lhs.id == rhs.id
  }
}

extension Repository: Hashable {
  var hashValue: Int {
    return id.hashValue
  }
}
