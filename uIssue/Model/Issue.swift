//
//  Issue.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation

struct Issue: Codable {
  let url: String
  let title: String
  let body: String
  let user: User
  let assignees: [User]
}

struct User: Codable {
  let avatar_url: String
  let login: String
  let id: Int
  let url: String
}
