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
  
  private func createViewModel(testRepo: Repository, repoIndex: Int) -> IssueListViewViewModel {
    return IssueListViewViewModel(repo: testRepo, repoIndex: repoIndex)
  }
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func test_fetchIssueList() {
    
  }
}
