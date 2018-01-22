//
//  RepoListViewViewModelTests.swift
//  uIssueTests
//
//  Created by junwoo on 2018. 1. 20..
//  Copyright © 2018년 samchon. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
@testable import uIssue

class RepoListViewViewModelTests: XCTestCase {
  
  var viewModel: RepoListViewViewModel!
  var scheduler: ConcurrentDispatchQueueScheduler!
  
  override func setUp() {
    super.setUp()
    viewModel = RepoListViewViewModel()
    scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func test_whenAccountAvailable_updatesAccountStatus() {
    let accountSubject = PublishSubject<UserNetworkManager.Status>()
    
    let loggedIn = viewModel.loggedIn.asObservable().subscribeOn(scheduler).materialize()
    
    accountSubject.onNext(.authorized)
    accountSubject.onNext(.unAuthorized)
    accountSubject.onCompleted()
    
    do {
      let emitted = try loggedIn.take(3).toBlocking(timeout: 1).toArray()
      XCTAssertEqual(emitted[0].element, UserNetworkManager.Status.authorized)
      XCTAssertEqual(emitted[1].element, UserNetworkManager.Status.unAuthorized)
      XCTAssertTrue(emitted[2].isCompleted)
    } catch {
      print(error)
      XCTFail()
    }
    
  }
  
}
