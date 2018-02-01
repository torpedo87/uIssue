//
//  CreateIssueViewViewModelTests.swift
//  uIssueTests
//
//  Created by junwoo on 2018. 1. 31..
//  Copyright © 2018년 samchon. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
@testable import uIssue

class CreateIssueViewViewModelTests: XCTestCase {
  
  var viewModel: CreateIssueViewViewModel!
  var scheduler: TestScheduler!
  var subscription: Disposable!
  
  override func setUp() {
    super.setUp()
    scheduler = TestScheduler(initialClock: 0)
  }
  
  override func tearDown() {
    super.tearDown()
    viewModel = nil
    LocalDataManager.shared.removeAll()
    scheduler.scheduleAt(1000) {
      //self.subscription.dispose()
    }
  }
  
  func createViewModel(repo: Repository, repoIndex: Int) -> CreateIssueViewViewModel {
    return CreateIssueViewViewModel(repo: repo, repoIndex: repoIndex, issueApi: TestAPIMock.shared)
  }
  
  func test_createIssueCallCreateIssueAPI() {
    LocalDataManager.shared.setRepoList(repoList: [Repository.test])
    DispatchQueue.main.async {
      TestAPIMock.shared.issueObjects.onNext(TestData().issue)
    }
    
    viewModel = createViewModel(repo: Repository.test, repoIndex: 0)
//    let eee = expectation(description: "aaa")
//    viewModel.createIssue(title: "title", newComment: "newComment")
//      .subscribe(onNext: { bool in
//        if bool {
//          XCTAssertEqual(TestAPIMock.shared.lastMethodCall, "createIssue(title:comment:label:repo:)")
//          eee.fulfill()
//        } else {
//          XCTFail()
//        }
//      })
//    waitForExpectations(timeout: 3, handler: nil)
    
    let result = try! viewModel.createIssue(title: "title", newComment: "newComment").toBlocking().first()!
    if result == true {
      XCTAssertEqual(TestAPIMock.shared.lastMethodCall, "createIssue(title:comment:label:repo:)")
      let result = try! LocalDataManager.shared.getProvider().toBlocking().first()!
      XCTAssertEqual(result[0].issuesDic?.count, 1)
      
    } else {
      XCTFail()
    }
  }
}
