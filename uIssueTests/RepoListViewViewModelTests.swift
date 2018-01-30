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
  
  private func createViewModel() -> RepoListViewViewModel {
    return RepoListViewViewModel(authApiType: TestAPIMock.self, issueApiType: TestAPIMock.self)
  }
  
  override func setUp() {
    super.setUp()
    viewModel = createViewModel()
    scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func test_fetchRepoListWhenStatusIsAuthorized() {
//    let statusSubject = PublishSubject<AuthService.Status>()
//    XCTAssertNil(viewModel.repoList.value)
//
//    let repoList = viewModel.repoList.asObservable()
//
//    DispatchQueue.main.async {
//      statusSubject.onNext(.authorized)
//    }
//
//    let emitted = try! repoList.take(2).toBlocking(timeout: 3).toArray()
//    XCTAssertNil(emitted[0])
//    XCTAssertNotNil(emitted[1][0].issuesDic)
  }
  
}
