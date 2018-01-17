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

enum Sort: String {
  case created
  case updated
  case comments
}

protocol IssueDataService {
  
  static func fetchIssueList(token: String, filter: Filter.RawValue, state: State.RawValue, sort: Sort.RawValue, completion: @escaping (_ issues: [Issue]?) -> Void)
  
}
