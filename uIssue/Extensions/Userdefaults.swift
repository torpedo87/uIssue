//
//  Userdefaults.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation

extension UserDefaults {
  
  func saveUser(user: User) {
    let dict = user.asDictionary
    UserDefaults.standard.set(dict, forKey: "user")
  }
  
  func loadUser() -> User? {
    guard let dict = UserDefaults.standard.dictionary(forKey: "user") else { return nil }
    guard let user = User(dictionary: dict) else { return nil }
    return user
  }
  
  func removeUser() {
    UserDefaults.standard.removeObject(forKey: "user")
  }
}
