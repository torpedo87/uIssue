//
//  Issue.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation

struct Issue: Codable {
  let id: Int
  let repository_url: String
  let title: String
  let body: String?
  let user: User
  let assignees: [User]
  let number: Int
  let repository: Repository?
}

struct User: Codable {
  let avatar_url: String
  let login: String
  let id: Int
  let url: String
}

struct Repository: Codable {
  let id: Int
  let name: String
  let owner: User
  let open_issues: Int
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
