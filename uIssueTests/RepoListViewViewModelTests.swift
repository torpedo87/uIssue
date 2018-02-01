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
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
    viewModel = nil
    LocalDataManager.shared.removeAll()
  }
  
  private func createViewModel(status: Driver<AuthService.Status>) -> RepoListViewViewModel {
    return RepoListViewViewModel(issueApi: TestAPIMock.shared, statusDriver: status)
  }
  
  func test_fetchRepoListWhenStatusIsAuthorized() {
    TestAPIMock.shared.reset()

    let statusSubject = PublishSubject<AuthService.Status>()
    viewModel = createViewModel(status: statusSubject.asDriver(onErrorJustReturn: AuthService.Status.unAuthorized("requestFail")))
    let repoList = viewModel.repoList.asObservable()

    DispatchQueue.main.async {
      statusSubject.onNext(.authorized)
      TestAPIMock.shared.issueArrObjects.onNext(TestData().issueArr)
    }

    let emitted = try! repoList.take(2).toBlocking(timeout: 3).toArray()
    XCTAssertEqual(emitted[0], [])
    XCTAssertEqual(emitted[1][0].name, "name")
    XCTAssertEqual(TestAPIMock.shared.lastMethodCall, "fetchAllIssues(filter:state:sort:page:)")
  }
  
}
