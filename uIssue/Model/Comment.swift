//
//  Comment.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 10..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation

struct Comment: Codable {
  let id: Int
  let user: User
  let created_at: String
  let body: String
  
  init(id: Int = -1, user: User = User(), created_at: String = "",
       body: String = "") {
    self.id = id
    self.user = user
    self.created_at = created_at
    self.body = body
  }
  
  static let test = Comment(id: 1, user: User.test, created_at: "1", body: "body")
}

struct IssueLabel: Codable {
  let name: String
  
  init(name: String = "") {
    self.name = name
  }
  
  static let test = IssueLabel(name: "debug")
}

extension Comment: Equatable {
  static func ==(lhs: Comment, rhs: Comment) -> Bool {
    return lhs.id == rhs.id
  }
}
