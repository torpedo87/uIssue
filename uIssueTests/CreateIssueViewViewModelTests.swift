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
  
  
  func createViewModel(repo: Repository, repoIndex: Int) -> CreateIssueViewViewModel {
    return CreateIssueViewViewModel(repo: repo, repoIndex: repoIndex, issueApi: TestAPIMock.shared)
  }
  
  func test_createIssue() {
    
//    LocalDataManager.shared.setRepoList(repoList: TestData().repoList)
//
//    let viewModel = createViewModel(repo: Repository.test, repoIndex: 0)
//
//    DispatchQueue.main.async {
//      TestAPIMock.shared.issueObjects.onNext(TestData().issue)
//    }
//    viewModel.createIssue(title: "title", newComment: "newComment")
//    
//    let emitted = try! LocalDataManager.shared.getProvider().take(1).toBlocking(timeout: 3).toArray()
//    XCTAssertEqual(emitted[0], [])
//    XCTAssertEqual(emitted[1][0].name, "name")
//    XCTAssertEqual(TestAPIMock.shared.lastMethodCall, "fetchAllIssues(filter:state:sort:page:)")
  }
}
