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

class TestAPIMock: AuthServiceRepresentable {
  
  static let shared: TestAPIMock = TestAPIMock()
  
  func reset() {
    lastMethodCall = nil
    statusObjects = PublishSubject<AuthService.Status>()
  }
  
  var statusObjects = PublishSubject<AuthService.Status>()
  var lastMethodCall: String?
  
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
