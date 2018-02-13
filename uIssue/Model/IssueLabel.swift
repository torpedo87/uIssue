//
//  IssueLabel.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 13..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation

struct IssueLabel: Codable {
  let name: String
  
  init(name: String = "") {
    self.name = name
  }
  
  static let test = IssueLabel(name: "debug")
}

extension IssueLabel: Equatable {
  static func ==(lhs: IssueLabel, rhs: IssueLabel) -> Bool {
    return lhs.name == rhs.name
  }
}

extension IssueLabel: Hashable {
  var hashValue: Int {
    return name.hashValue
  }
}
