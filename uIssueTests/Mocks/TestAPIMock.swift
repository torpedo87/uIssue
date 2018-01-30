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
  
  static func reset() {
    lastMethodCall = nil
    issueArrObjects = PublishSubject<[Issue]>()
    issueObjects = PublishSubject<Issue>()
    statusObjects = PublishSubject<AuthService.Status>()
    commentArrObjects = PublishSubject<[Comment]>()
    commentObjects = PublishSubject<Comment>()
    boolObjects = PublishSubject<Bool>()
  }
  
  static var statusObjects = PublishSubject<AuthService.Status>()
  static var issueArrObjects = PublishSubject<[Issue]>()
  static var issueObjects = PublishSubject<Issue>()
  static var commentArrObjects = PublishSubject<[Comment]>()
  static var commentObjects = PublishSubject<Comment>()
  static var boolObjects = PublishSubject<Bool>()
  static var lastMethodCall: String?
  
  static var currentPage: Variable<Int>
  
  static func fetchAllIssues(filter: IssueService.Filter, state: IssueService.State, sort: IssueService.Sort, page: Int) -> Observable<[Issue]> {
    lastMethodCall = #function
    return issueArrObjects.asObservable()
  }
  
  static func createIssue(title: String, comment: String, label: [IssueService.Label], repo: Repository) -> Observable<Issue> {
    lastMethodCall = #function
    return issueObjects.asObservable()
  }
  
  static func editIssue(title: String, comment: String, label: [IssueService.Label], issue: Issue, state: IssueService.State, repo: Repository) -> Observable<Issue> {
    lastMethodCall = #function
    return issueObjects.asObservable()
  }
  
  static func fetchComments(issue: Issue) -> Observable<[Comment]> {
    lastMethodCall = #function
    return commentArrObjects.asObservable()
  }
  
  static func createComment(issue: Issue, commentBody: String) -> Observable<Comment> {
    lastMethodCall = #function
    return commentObjects.asObservable()
  }
  
  static func editComment(issue: Issue, comment: Comment, newCommentText: String) -> Observable<Comment> {
    lastMethodCall = #function
    return commentObjects.asObservable()
  }
  
  static func deleteComment(issue: Issue, comment: Comment) -> Observable<Bool> {
    lastMethodCall = #function
    return boolObjects.asObservable()
  }
  
  static var status: Driver<AuthService.Status> {
    return Observable.create { observer in
      if let _ = UserDefaults.loadToken() {
        observer.onNext(.authorized)
      } else {
        observer.onNext(.unAuthorized("caanot load token"))
      }
      return Disposables.create()
      }.asDriver(onErrorJustReturn: AuthService.Status.unAuthorized("unAuthorized"))
  }
  
  static func requestToken(userId: String, userPassword: String) -> Observable<AuthService.Status> {
    lastMethodCall = #function
    return statusObjects.asObservable()
  }
  
  static func removeToken(userId: String, userPassword: String) -> Observable<AuthService.Status> {
    lastMethodCall = #function
    return statusObjects.asObservable()
  }
  
}
