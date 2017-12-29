//
//  Userdefaults.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation

extension UserDefaults {
  
  func saveMe(user: Me) {
    let dict = user.asDictionary
    UserDefaults.standard.set(dict, forKey: "me")
  }
  
  func loadMe() -> Me? {
    guard let dict = UserDefaults.standard.dictionary(forKey: "me") else { return nil }
    guard let me = Me(dictionary: dict) else { return nil }
    return me
  }
  
  func removeMe() {
    UserDefaults.standard.removeObject(forKey: "me")
  }
}
