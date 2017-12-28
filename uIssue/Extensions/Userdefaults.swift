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
  
  func loadUser() -> User {
    guard let dict = UserDefaults.standard.dictionary(forKey: "user") as? [String:Any] else { fatalError() }
    guard let user = User(dictionary: dict) as? User else { fatalError() }
    return user
  }
}
