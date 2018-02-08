//
//  Userdefaults.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension UserDefaults {
  
  static func saveToken(token: Token) {
    
    let dict = token.asDictionary
    UserDefaults.standard.set(dict, forKey: "token")

  }
  
  static func loadToken() -> Token? {
    guard let dict =
      UserDefaults.standard.dictionary(forKey: "token") else { return nil }
    if let id = dict["id"] as? Int, let token = dict["token"] as? String {
      let newToken = Token(id: id, token: token)
      return newToken
    }
    return nil
  }
  
  static func removeLocalToken() {
    UserDefaults.standard.removeObject(forKey: "token")
  }
}
