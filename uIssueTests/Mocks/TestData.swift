//
//  TestData.swift
//  uIssueTests
//
//  Created by junwoo on 2018. 1. 30..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
@testable import uIssue

class TestData {
  var issueArr: [Issue] = [Issue.test, Issue.test, Issue.test]
  var issue: Issue = Issue.test
  lazy var repoList: [Repository] = {
    return [
      Repository(id: 1, name: "name1", owner: User.test, open_issues: 2, created_at: "1", issuesDic: [2:Issue.test]),
      Repository(id: 2, name: "name2", owner: User.test, open_issues: 1, created_at: "2", issuesDic: [1:Issue.test])
    ]
  }()
}
