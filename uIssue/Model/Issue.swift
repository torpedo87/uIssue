//
//  Issue.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation

struct Issue: Codable {
  let id: Int
  let title: String
  let body: String?
  let user: User
  let assignees: [User]
  let number: Int
  var repository: Repository?
  let created_at: String
  let updated_at: String
  let labels: [IssueLabel]
  let state: String
  let comments_url: String
  var commentsDic: [Int:Comment]?
  var isCommentsFetched: Bool?
  
  init(id: Int = -1, title: String = "", body: String? = nil, user: User = User(),
       assignees: [User] = [], number: Int = -1, repository: Repository? = nil,
       created_at: String = "", updated_at: String = "", labels: [IssueLabel] = [],
       state: String = "", comments_url: String = "", commentsDic: [Int:Comment]? = nil,
       isCommentsFetched: Bool = false) {
    self.id = id
    self.title = title
    self.body = body
    self.user = user
    self.assignees = assignees
    self.number = number
    self.repository = repository
    self.created_at = created_at
    self.updated_at = updated_at
    self.labels = labels
    self.state = state
    self.comments_url = comments_url
    self.commentsDic = commentsDic
    self.isCommentsFetched = isCommentsFetched
  }
  
  mutating func setCommentsDic(comments: [Comment]) {
    self.isCommentsFetched = true
    self.commentsDic = [Int:Comment]()
    for comment in comments {
      self.commentsDic?[comment.id] = comment
    }
  }
  
  static let test =
    Issue(id: 1, title: "title", body: "body", user: User.test,
                          assignees: [User.test], number: 1,
                          repository: Repository.test, created_at: "1",
                          labels: [IssueLabel.test],
                          state: IssueService.State.open.rawValue,
                          comments_url: "comments_url", commentsDic: nil)
}


extension Issue: Equatable {
  static func ==(lhs: Issue, rhs: Issue) -> Bool {
    return lhs.id == rhs.id
  }
}
