//
//  IssueListViewViewModelTests.swift
//  uIssueTests
//
//  Created by junwoo on 2018. 1. 30..
//  Copyright © 2018년 samchon. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
@testable import uIssue

class IssueListViewViewModelTests: XCTestCase {
  
  var viewModel: IssueListViewViewModel!
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
    viewModel = nil
    LocalDataManager.shared.removeAll()
  }
  
  private func createViewModel(testRepo: Repository, repoIndex: Int) -> IssueListViewViewModel {
    return IssueListViewViewModel(repo: testRepo, repoIndex: repoIndex)
  }
  
  func test_fetchIssueList() {
    
    //viewmodel 만들기
    viewModel = createViewModel(testRepo: Repository.test, repoIndex: 0)
    let issueList = viewModel.issueList.asObservable()
    
    //local 에 추가
    DispatchQueue.main.async {
      LocalDataManager.shared.setRepoList(repoList: TestData().repoList)
    }
    
    let emitted = try! issueList.take(2).toBlocking(timeout: 3).toArray()
    XCTAssertEqual(emitted[0], [])
    //XCTAssertEqual(emitted[1][0].id, 1)
  }
}
