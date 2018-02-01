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
  var editedIssue: Issue = Issue(id: 1, title: "edited", body: "edited", user: User.test, assignees: [User.test], number: 1, repository: Repository.test, created_at: "1", labels: [IssueLabel.test], state: IssueService.State.open.rawValue, comments_url: "comments_url", commentsDic: nil)
  lazy var issueWithComment: Issue = Issue(id: 1, title: "title", body: "body", user: User.test, assignees: [User.test], number: 1, repository: Repository.test, created_at: "1", labels: [IssueLabel.test], state: IssueService.State.open.rawValue, comments_url: "url", commentsDic: [1:comment])
  lazy var repoListWithComment: [Repository] = {
    return [
      Repository(id: 1, name: "name1", owner: User.test, open_issues: 1, created_at: "1", issuesDic: [1:issueWithComment])
    ]
  }()
  lazy var repoList: [Repository] = {
    return [
      Repository(id: 1, name: "name1", owner: User.test, open_issues: 2, created_at: "1", issuesDic: [1:Issue.test]),
      Repository(id: 2, name: "name2", owner: User.test, open_issues: 1, created_at: "2", issuesDic: [1:Issue.test]),
    ]
  }()
  
  lazy var commentsList: [Comment] = {
    return [
      Comment(id: 1, user: User.test, created_at: "1", body: "body1"),
      Comment(id: 2, user: User.test, created_at: "2", body: "body2"),
      Comment(id: 3, user: User.test, created_at: "3", body: "body3")
    ]
  }()
  
  var comment: Comment = Comment(id: 1, user: User.test, created_at: "1", body: "new")
  var editedComment: Comment = Comment(id: 1, user: User.test, created_at: "1", body: "edited")
}
