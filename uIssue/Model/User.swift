//
//  User.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation

struct User {
  
  private var id: String
  private var password: String
  private var tokenId: Int
  private var token: String
  
  init(id: String, password: String, tokenId: Int, token: String) {
    self.id = id
    self.password = password
    self.tokenId = tokenId
    self.token = token
  }
  
  var asDictionary: [String:Any] {
    return [
      "id": id,
      "password": password,
      "tokenId": tokenId,
      "token": token
    ]
  }
  
  init?(dictionary: [String:Any]) {
    guard let id = dictionary["id"] as? String else { return nil }
    guard let password = dictionary["password"] as? String else { return nil }
    guard let tokenId = dictionary["tokenId"] as? Int else { return nil }
    guard let token = dictionary["token"] as? String else { return nil }
    
    self.id = id
    self.password = password
    self.tokenId = tokenId
    self.token = token
  }
  
  func getId() -> String {
    return id
  }
  
  func getPassword() -> String {
    return password
  }
  
  func getTokenId() -> Int {
    return tokenId
  }
  
  func getToken() -> String {
    return token
  }
}
