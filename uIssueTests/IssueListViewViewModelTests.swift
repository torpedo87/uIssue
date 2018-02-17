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
  
//  var viewModel: IssueListViewViewModel!
//  
//  override func setUp() {
//    super.setUp()
//  }
//  
//  override func tearDown() {
//    super.tearDown()
//    viewModel = nil
//    LocalDataManager.shared.removeAll()
//  }
//  
//  private func createViewModel(repoId: Int) -> IssueListViewViewModel {
//    return IssueListViewViewModel(repoId: repoId)
//  }
//  
//  func test_fetchIssueList() {
//    
//    //viewmodel 만들기
//    viewModel = createViewModel(repoId: 1)
//    let issueList = viewModel.issueList.asObservable()
//    
//    //local 에 추가
//    DispatchQueue.main.async {
//      LocalDataManager.shared.setRepoDict(repoDict: TestData().repoDict)
//    }
//    
//    let emitted = try! issueList.skip(1).toBlocking().first()
//    XCTAssertEqual(emitted![0], Issue.test)
//  }
}
