//
//  Issue.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation

protocol Sortable {
  var created_at: String { get }
}

struct Issue: Codable, Sortable {
  var id: Int
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
  var commentsDic: [Int:Comment]?
  
  mutating func setCommentsDic(comments: [Comment]) {
    self.commentsDic = [Int:Comment]()
    for comment in comments {
      self.commentsDic?[comment.id] = comment
    }
  }
}

struct Comment: Codable, Sortable {
  var id: Int
  var user: User
  var created_at: String
  var body: String
  var issue: Issue?
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

struct Repository: Codable, Sortable {
  var id: Int
  var name: String
  var owner: User
  var open_issues: Int
  var created_at: String
  var issuesDic: [Int:Issue]?
  
  mutating func setIssuesDic(issueArr: [Issue]) {
    self.issuesDic = [Int:Issue]()
    for i in 0..<issueArr.count {
      self.issuesDic?[issueArr[i].id] = issueArr[i]
    }
  }
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
