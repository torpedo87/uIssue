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
  let id: Int
  let title: String
  let body: String?
  let user: User
  let assignees: [User]
  let number: Int
  let repository: Repository?
  let created_at: String
  let labels: [IssueLabel]
  let state: String
  let comments_url: String
  var commentsDic: [Int:Comment]?
  
  init(id: Int = -1, title: String = "", body: String? = nil, user: User = User(),
       assignees: [User] = [User()], number: Int = -1, repository: Repository? = nil,
       created_at: String = "", labels: [IssueLabel] = [IssueLabel()], state: String = "",
       comments_url: String = "", commentsDic: [Int:Comment]? = nil) {
    self.id = id
    self.title = title
    self.body = body
    self.user = user
    self.assignees = assignees
    self.number = number
    self.repository = repository
    self.created_at = created_at
    self.labels = labels
    self.state = state
    self.comments_url = comments_url
    self.commentsDic = commentsDic
  }
  
  mutating func setCommentsDic(comments: [Comment]) {
    self.commentsDic = [Int:Comment]()
    for comment in comments {
      self.commentsDic?[comment.id] = comment
    }
  }
}

struct Comment: Codable, Sortable {
  let id: Int
  let user: User
  let created_at: String
  let body: String
  
  init(id: Int = -1, user: User = User(), created_at: String = "",
       body: String = "", issue: Issue? = nil) {
    self.id = id
    self.user = user
    self.created_at = created_at
    self.body = body
  }
}

struct IssueLabel: Codable {
  let name: String
  
  init(name: String = "") {
    self.name = name
  }
}

struct User: Codable {
  let avatar_url: String
  let login: String
  let id: Int
  let url: String
  
  init(avatar_url: String = "", login: String = "", id: Int = -1, url: String = "") {
    self.avatar_url = avatar_url
    self.login = login
    self.id = id
    self.url = url
  }
}

struct Repository: Codable, Sortable {
  let id: Int
  let name: String
  let owner: User
  let open_issues: Int
  let created_at: String
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
