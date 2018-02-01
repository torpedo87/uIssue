//
//  IssueDetailViewViewModelTests.swift
//  uIssueTests
//
//  Created by junwoo on 2018. 2. 1..
//  Copyright © 2018년 samchon. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
@testable import uIssue

class IssueDetailViewViewModelTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    
  }
  
  override func tearDown() {
    LocalDataManager.shared.removeAll()
    super.tearDown()
  }
  
  func createViewModel(issue: Issue, issueIndex: Int, repoIndex: Int) -> IssueDetailViewViewModel {
    return IssueDetailViewViewModel(issue: issue, issueIndex: issueIndex, repoIndex: repoIndex, issueApi: TestAPIMock.shared)
  }
  
  func test_requestFetchComments_changeLocal() {
    LocalDataManager.shared.setRepoList(repoList: TestData().repoList)
    DispatchQueue.main.async {
      TestAPIMock.shared.commentArrObjects.onNext(TestData().commentsList)
    }
    
    let viewModel = createViewModel(issue: Issue.test, issueIndex: 0, repoIndex: 0)
    viewModel.requestFetchComments()
    
    let result = try! LocalDataManager.shared.getProvider().skip(1).toBlocking().first()
    XCTAssertNotNil(result![0].issuesDic![1]?.commentsDic)
    XCTAssertEqual(result![0].issuesDic![1]?.commentsDic![1]?.body, "body1")
  }
  
  func test_editIssue_changeLocal() {
    LocalDataManager.shared.setRepoList(repoList: TestData().repoList)
    DispatchQueue.main.async {
      TestAPIMock.shared.issueObjects.onNext(TestData().editedIssue)
    }
    
    let viewModel = createViewModel(issue: Issue.test, issueIndex: 0, repoIndex: 0)
    let bool = try! viewModel.editIssue(state: IssueService.State.open, newTitleText: "newTitle", newCommentText: "newBody", label: [.enhancement]).toBlocking().first()
    
    if bool! {
      let result = try! LocalDataManager.shared.getProvider().toBlocking().first()
      XCTAssertEqual(result![0].issuesDic![1]?.body, "edited")
    } else {
      XCTFail()
    }
  }
  
  func test_closeIssue_changeLocal() {
    LocalDataManager.shared.setRepoList(repoList: TestData().repoList)
    DispatchQueue.main.async {
      TestAPIMock.shared.issueObjects.onNext(TestData().editedIssue)
    }
    let viewModel = createViewModel(issue: Issue.test, issueIndex: 0, repoIndex: 0)
    let bool = try! viewModel.editIssue(state: IssueService.State.closed, newTitleText: "newTitle", newCommentText: "newBody", label: [.enhancement]).toBlocking().first()
    
    if bool! {
      let result = try! LocalDataManager.shared.getProvider().toBlocking().first()
      XCTAssertEqual(result![0].issuesDic!.count, 0)
    } else {
      XCTFail()
    }
  }
  
  func test_createComment_changeLocal() {
    LocalDataManager.shared.setRepoList(repoList: TestData().repoList)
    DispatchQueue.main.async {
      TestAPIMock.shared.commentObjects.onNext(TestData().comment)
    }
    let viewModel = createViewModel(issue: Issue.test, issueIndex: 0, repoIndex: 0)
    let bool = try! viewModel.createComment(issue: Issue.test, newCommentBody: "new", repoIndex: 0).toBlocking().first()
    
    if bool! {
      let result = try! LocalDataManager.shared.getProvider().toBlocking().first()
      XCTAssertEqual(result![0].issuesDic![1]!.commentsDic?.count, 1)
    } else {
      XCTFail()
    }
  }
}
