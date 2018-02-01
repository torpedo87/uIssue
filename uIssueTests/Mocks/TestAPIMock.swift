//
//  TestAPIMock.swift
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

class TestAPIMock: AuthServiceRepresentable, IssueServiceRepresentable {
  
  static let shared: TestAPIMock = TestAPIMock()
  
  func reset() {
    lastMethodCall = nil
    issueArrObjects = PublishSubject<[Issue]>()
    issueObjects = PublishSubject<Issue>()
    statusObjects = PublishSubject<AuthService.Status>()
    commentArrObjects = PublishSubject<[Comment]>()
    commentObjects = PublishSubject<Comment>()
    boolObjects = PublishSubject<Bool>()
  }
  
  var statusObjects = PublishSubject<AuthService.Status>()
  var issueArrObjects = PublishSubject<[Issue]>()
  var issueObjects = PublishSubject<Issue>()
  var commentArrObjects = PublishSubject<[Comment]>()
  var commentObjects = PublishSubject<Comment>()
  var boolObjects = PublishSubject<Bool>()
  var lastMethodCall: String?
  
  var currentPage: Variable<Int> = Variable<Int>(1)
  
  func fetchAllIssues(filter: IssueService.Filter, state: IssueService.State, sort: IssueService.Sort, page: Int) -> Observable<[Issue]> {
    print("======fetchAllIssueMock---------")
    lastMethodCall = #function
    return issueArrObjects.asObservable()
  }
  
  func createIssue(title: String, comment: String, label: [IssueService.Label], repo: Repository) -> Observable<Issue> {
    print("======createIssueMock---------")
    lastMethodCall = #function
    return issueObjects.asObservable()
  }
  
  func editIssue(title: String, comment: String, label: [IssueService.Label], issue: Issue, state: IssueService.State, repo: Repository) -> Observable<Issue> {
    lastMethodCall = #function
    return issueObjects.asObservable()
  }
  
  func fetchComments(issue: Issue) -> Observable<[Comment]> {
    lastMethodCall = #function
    return commentArrObjects.asObservable()
  }
  
  func createComment(issue: Issue, commentBody: String) -> Observable<Comment> {
    lastMethodCall = #function
    return commentObjects.asObservable()
  }
  
  func editComment(issue: Issue, comment: Comment, newCommentText: String) -> Observable<Comment> {
    lastMethodCall = #function
    return commentObjects.asObservable()
  }
  
  func deleteComment(issue: Issue, comment: Comment) -> Observable<Bool> {
    lastMethodCall = #function
    return boolObjects.asObservable()
  }
  
  var status: Driver<AuthService.Status> {
    return Observable.create { observer in
      observer.onNext(.authorized)
      return Disposables.create()
      }.asDriver(onErrorJustReturn: AuthService.Status.unAuthorized("unAuthorized"))
  }
  
  func requestToken(userId: String, userPassword: String) -> Observable<AuthService.Status> {
    lastMethodCall = #function
    return statusObjects.asObservable()
  }
  
  func removeToken(userId: String, userPassword: String) -> Observable<AuthService.Status> {
    lastMethodCall = #function
    return statusObjects.asObservable()
  }
  
}
