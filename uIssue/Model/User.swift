//
//  User.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 10..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation

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
  
  static let test = User(avatar_url: "avatar_url", login: "login", id: 1, url: "url")
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
