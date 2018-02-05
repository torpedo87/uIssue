//
//  Me.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 3..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation

class Me {
  
  static let shared = Me()
  
  private var user: User?
  
  func setUser(me: User) {
    self.user = me
  }
  
  func getUser() -> User? {
    return user
  }
}
