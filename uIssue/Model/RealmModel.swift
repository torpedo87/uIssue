//
//  RealmModel.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 23..
//  Copyright © 2018년 samchon. All rights reserved.
//
import Foundation
import RealmSwift

class RealmIssue: Object {
  
  convenience init(id: Int) {
    self.init()
    self.id = id
  }
  
  @objc dynamic var id: Int = 0
  @objc dynamic var title: String = ""
  @objc dynamic var body: String? = nil
  //user
  //assignees
  @objc dynamic var number: Int = 0
  //repo
  @objc dynamic var created_at: String = ""
  @objc dynamic var updated_at: String = ""
  //labels
  @objc dynamic var state: String = ""
  @objc dynamic var comments_url: String = ""
  //commentsDic
  
  override static func primaryKey() -> String? {
    return "id"
  }
}

class RealmUser: Object {
  convenience init(id: Int) {
    self.init()
    self.id = id
  }
  @objc dynamic var avatar_url: String = ""
  @objc dynamic var login: String = ""
  @objc dynamic var id: Int = 0
  @objc dynamic var url: String = ""
  
  override static func primaryKey() -> String? {
    return "id"
  }
}
