//
//  IssueService.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation
import RxSwift
import Moya

protocol IssueServiceRepresentable {
  var currentPage: Variable<Int> { get }
  func fetchAllIssues(filter: IssueService.Filter, state: IssueService.State, sort: IssueService.Sort, page: Int) -> Observable<[Issue]>
  func createIssue(title: String, body: String, label: [IssueService.Label], repo: Repository) -> Observable<Issue>
  func editIssue(title: String, body: String, label: [IssueService.Label], issue: Issue, state: IssueService.State, repo: Repository) -> Observable<Issue>
  func fetchComments(issue: Issue) -> Observable<[Comment]>
  func createComment(issue: Issue, commentBody: String) -> Observable<Comment>
  func editComment(issue: Issue, comment: Comment, newCommentText: String) -> Observable<Comment>
  func deleteComment(issue: Issue, comment: Comment) -> Observable<Bool>
  func getUser() -> Observable<Bool>
}

class IssueService: IssueServiceRepresentable {
  
  var currentPage: Variable<Int> = Variable<Int>(1)
  var lastPage = Variable<Int>(-1)
  private var tempIssueArr = [Issue]()
  let provider = MoyaProvider<IssueAPI>()
  
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
  
  enum Label: String {
    case bug
    case duplicate
    case enhancement
    case goodFirstIssue = "good first issue"
    case helpWanted = "help wanted"
    case invalid
    case model
    case question
    case wontfix
  }
  
  func fetchAllIssues(filter: Filter, state: State, sort: Sort, page: Int) -> Observable<[Issue]> {
    return self.provider.rx.request(.fetchAllIssues(filter: filter, state: state, sort: sort, page: page))
      .asObservable()
      .map { [weak self] (result) -> [Issue] in
        let response = result.response!
        let data = result.data
        if let link = response.allHeaderFields["Link"] as? String, self?.lastPage.value == -1 {
          self?.lastPage.value = (self?.getLastPageFromLinkHeader(link: link))!
        }
        if 200 ..< 300 ~= response.statusCode {
          let issues = try! JSONDecoder().decode([Issue].self, from: data)
          for issue in issues {
            self?.tempIssueArr.append(issue)
          }
          if (self?.currentPage.value)! < (self?.lastPage.value)! {
            self?.currentPage.value += 1
            return []
          }
          return (self?.tempIssueArr)!
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }.catchError({ (error) -> Observable<[Issue]> in
        return Observable.just([])
      })
    
  }
  
  func createIssue(title: String, body: String, label: [Label], repo: Repository) -> Observable<Issue> {
    return self.provider.rx.request(.createIssue(title: title, body: body, label: label, repo: repo))
      .asObservable()
      .map({ (result) -> Issue in
        let response = result.response!
        let data = result.data
        if 200 ..< 300 ~= response.statusCode {
          let newIssue = try! JSONDecoder().decode(Issue.self, from: data)
          return newIssue
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }).catchError({ (error) -> Observable<Issue> in
        return Observable.just(Issue())
      })
  }
  
  
  
  func editIssue(title: String, body: String, label: [Label], issue: Issue, state: State, repo: Repository) -> Observable<Issue> {
    
    return self.provider.rx.request(.editIssue(title: title, body: body, label: label, issue: issue, state: state, repo: repo))
      .asObservable()
      .map({ (result) -> Issue in
        let response = result.response!
        let data = result.data
        if 200 ..< 300 ~= response.statusCode {
          let newIssue = try! JSONDecoder().decode(Issue.self, from: data)
          return newIssue
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }).catchError({ (error) -> Observable<Issue> in
        return Observable.just(Issue())
      })
    
  }
  
  func fetchComments(issue: Issue) -> Observable<[Comment]> {
    
    return self.provider.rx.request(.fetchComments(issue: issue))
      .asObservable()
      .map({ (result) -> [Comment] in
        let response = result.response!
        let data = result.data
        if 200 ..< 300 ~= response.statusCode {
          let comments = try! JSONDecoder().decode([Comment].self, from: data)
          
          return comments
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }).catchError({ (error) -> Observable<[Comment]> in
        return Observable.just([])
      })
  }
  
  func createComment(issue: Issue, commentBody: String) -> Observable<Comment> {
    return self.provider.rx.request(.createComment(issue: issue, commentBody: commentBody))
      .asObservable()
      .map({ (result) -> Comment in
        let response = result.response!
        let data = result.data
        if 200 ..< 300 ~= response.statusCode {
          let newComment = try! JSONDecoder().decode(Comment.self, from: data)
          return newComment
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }).catchError({ (error) -> Observable<Comment> in
        return Observable.just(Comment())
      })
  }
  
  
  
  func editComment(issue: Issue, comment: Comment, newCommentText: String) -> Observable<Comment> {
    return self.provider.rx.request(.editComment(issue: issue, comment: comment, newCommentText: newCommentText))
      .asObservable()
      .map({ (result) -> Comment in
        let response = result.response!
        let data = result.data
        if 200 ..< 300 ~= response.statusCode {
          let newComment = try! JSONDecoder().decode(Comment.self, from: data)
          return newComment
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }).catchError({ (error) -> Observable<Comment> in
        return Observable.just(Comment())
      })
    
  }
  
  func deleteComment(issue: Issue, comment: Comment) -> Observable<Bool> {
    return self.provider.rx.request(.deleteComment(issue: issue, comment: comment))
      .asObservable()
      .map({ (result) -> Bool in
        let response = result.response!
        if 200 ..< 300 ~= response.statusCode {
          return true
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }).catchError({ (error) -> Observable<Bool> in
        return Observable.just(false)
      })
  }
  
  func getUser() -> Observable<Bool> {
    return self.provider.rx.request(.getUser())
      .asObservable()
      .map({ (result) -> Bool in
        let response = result.response!
        let data = result.data
        if 200 ..< 300 ~= response.statusCode {
          let me = try! JSONDecoder().decode(User.self, from: data)
          Me.shared.setUser(me: me)
          return true
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }).catchError({ (error) -> Observable<Bool> in
        return Observable.just(false)
      })
  }
  
  //helper
  func getLastPageFromLinkHeader(link: String) -> Int {
    let temp = link.components(separatedBy: "=")[7]
    let lastPage = Int((temp.components(separatedBy: "&")[0]))!
    return lastPage
  }
}
