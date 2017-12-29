//
//  IssueDataService.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation

enum Filter: String {
  case assigned
  case created
  case mentioned
  case subscribed
  case all
}

enum State: String {
  case open
  case closed
  case all
}

protocol IssueDataService {
  
  static func fetchIssueList(userId: String, userPassword: String, filter: Filter.RawValue, state: State.RawValue, completion: @escaping (_ issues: [Issue]?) -> Void)
  
}
