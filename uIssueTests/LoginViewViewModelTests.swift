//
//  LoginViewViewModelTests.swift
//  uIssueTests
//
//  Created by junwoo on 2018. 1. 19..
//  Copyright © 2018년 samchon. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
@testable import uIssue

class LoginViewViewModelTests: XCTestCase {
  
  var viewModel: LoginViewViewModel!
  var scheduler: ConcurrentDispatchQueueScheduler!
  
  override func setUp() {
    super.setUp()
    viewModel = LoginViewViewModel()
    scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testRequestLoginFail() {
    let loginStatusObservable = viewModel.requestLogin(id: "test", password: "test").subscribeOn(scheduler)
    
    do {
      guard let result = try loginStatusObservable.toBlocking(timeout: 5.0).first() else { return }
      XCTAssertEqual(result, .unAuthorized)
    } catch {
      print(error)
    }
  }
  
}
