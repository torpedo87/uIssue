//
//  Issue.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation

struct Issue: Codable {
  var id: Int
  var repository_url: String
  var title: String
  var body: String?
  var user: User
  var assignees: [User]
  var number: Int
  var repository: Repository?
  var created_at: String
  var labels: [IssueLabel]
  var state: String
  var comments_url: String
  var commentsArr: [Comment]?
}

struct Comment: Codable {
  var user: User
  var created_at: String
  var body: String
}

struct IssueLabel: Codable {
  var name: String
}

struct User: Codable {
  var avatar_url: String
  var login: String
  var id: Int
  var url: String
}

struct Repository: Codable {
  var id: Int
  var name: String
  var owner: User
  var open_issues: Int
  var created_at: String
  var issueArr: [Issue]?
}

extension Issue: Equatable {
  static func ==(lhs: Issue, rhs: Issue) -> Bool {
    return lhs.id == rhs.id
  }
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

extension User: Equatable {
  static func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
  }
}

extension User: Hashable {
  var hashValue: Int {
    return id.hashValue
  }
}
