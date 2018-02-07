//
//  IssueAPI.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 3..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation
import Moya

enum IssueAPI {
  
  case fetchAllIssues(filter: IssueService.Filter, state: IssueService.State, sort: IssueService.Sort, page: Int)
  case createIssue(title: String, body: String, label: [IssueService.Label], repo: Repository, users: [User])
  case editIssue(title: String, body: String, label: [IssueService.Label], issue: Issue, state: IssueService.State, repo: Repository, assignees: [User])
  case fetchComments(issue: Issue)
  case createComment(issue: Issue, commentBody: String)
  case editComment(issue: Issue, comment: Comment, newCommentText: String)
  case deleteComment(issue: Issue, comment: Comment)
  case getUser()
  case getAssignees(repo: Repository)
}

extension IssueAPI: TargetType {
  
  var sampleData: Data {
    return Data()
  }
  
  var headers: [String : String]? {
    guard let token = UserDefaults.loadToken()?.token else { fatalError() }
    return [
      "Content-type": "application/json; charset=utf-8",
      "Authorization": "Bearer \(token)"
    ]
  }
  
  var baseURL: URL { return URL(string: "https://api.github.com")! }
  
  var path: String {
    switch self {
    case .fetchAllIssues(_, _, _, _):
      return "/issues"
    case .getUser():
      return "/user"
    case .createIssue(_, _, _, let repo, _):
      return "/repos/\(repo.owner.login)/\(repo.name)/issues"
    case .editIssue(_, _, _, let issue, _, let repo, _):
      return "/repos/\(issue.user.login)/\(repo.name)/issues/\(issue.number)"
    case .fetchComments(let issue):
      return "/repos/\(issue.user.login)/\(issue.repository!.name)/issues/\(issue.number)/comments"
    case .createComment(let issue, _):
      return "/repos/\(issue.repository!.owner.login)/\(issue.repository!.name)/issues/\(issue.number)/comments"
    case .editComment(let issue, let comment, _), .deleteComment(let issue, let comment):
      return "/repos/\(issue.repository!.owner.login)/\(issue.repository!.name)/issues/comments/\(comment.id)"
    case .getAssignees(let repo):
      return "/repos/\(repo.owner.login)/\(repo.name)/assignees"
    }
  }
  
  var method: Moya.Method {
    switch self {
    case .fetchAllIssues, .fetchComments, .getUser, .getAssignees:
      return .get
    case .createIssue, .createComment:
      return .post
    case .editIssue, .editComment:
      return .patch
    case .deleteComment:
      return .delete
    }
  }
  
  var task: Task {
    switch self {
    case .fetchComments, .deleteComment, .getUser, .getAssignees:
      return .requestPlain
      
    case let .fetchAllIssues(filter, state, sort, page):
      return .requestParameters(parameters: ["sort": sort.rawValue, "state": state.rawValue, "filter": filter.rawValue, "page": "\(page)"], encoding: URLEncoding.queryString)
      
    case let .createIssue(title, body, label, _, users):
      return .requestParameters(parameters: ["body": body, "labels": label.map{ $0.rawValue }, "title": title, "assignees": users.map{ $0.login }], encoding: JSONEncoding.default)
      
    case let .editIssue(title, body, label, _, state, _, assignees):
      return .requestParameters(parameters: ["body": body, "labels": label.map{ $0.rawValue }, "title": title, "state": state.rawValue, "assignees": assignees.map{ $0.login }], encoding: JSONEncoding.default)
    case let .createComment(_, commentBody):
      return .requestParameters(parameters: ["body": commentBody], encoding: JSONEncoding.default)
    case let .editComment(_, _, newCommentText):
      return .requestParameters(parameters: ["body": newCommentText], encoding: JSONEncoding.default)
    }
  }
}
