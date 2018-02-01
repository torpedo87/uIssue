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
  
  func test_editComment_changeLocal() {
    LocalDataManager.shared.setRepoList(repoList: TestData().repoListWithComment)
    DispatchQueue.main.async {
      TestAPIMock.shared.commentObjects.onNext(TestData().editedComment)
    }
    let viewModel = createViewModel(issue: Issue.test, issueIndex: 0, repoIndex: 0)
    let bool = try! viewModel.editComment(issue: Issue.test, existingComment: Comment.test, repoIndex: 0, newCommentText: "edited").toBlocking().first()
    
    if bool! {
      let result = try! LocalDataManager.shared.getProvider().toBlocking().first()
      XCTAssertEqual(result![0].issuesDic![1]!.commentsDic?[1]?.body, "edited")
    } else {
      XCTFail()
    }
  }
  
  func test_deleteComment_changeLocalWhenAPISucceed() {
    LocalDataManager.shared.setRepoList(repoList: TestData().repoListWithComment)
    DispatchQueue.main.async {
      TestAPIMock.shared.boolObjects.onNext(true)
    }
    let viewModel = createViewModel(issue: Issue.test, issueIndex: 0, repoIndex: 0)
    let bool = try! viewModel.deleteComment(issue: Issue.test, existingComment: Comment.test, repoIndex: 0).toBlocking().first()
    
    if bool! {
      let result = try! LocalDataManager.shared.getProvider().toBlocking().first()
      XCTAssertNil(result![0].issuesDic![1]!.commentsDic?[1])
    } else {
      XCTFail()
    }
  }
  
  func test_deleteComment_changeLocalWhenAPIFail() {
    LocalDataManager.shared.setRepoList(repoList: TestData().repoListWithComment)
    DispatchQueue.main.async {
      TestAPIMock.shared.boolObjects.onNext(false)
    }
    let viewModel = createViewModel(issue: Issue.test, issueIndex: 0, repoIndex: 0)
    let bool = try! viewModel.deleteComment(issue: Issue.test, existingComment: Comment.test, repoIndex: 0).toBlocking().first()
    
    if bool! {
      XCTFail()
    } else {
      let result = try! LocalDataManager.shared.getProvider().toBlocking().first()
      XCTAssertNotNil(result![0].issuesDic![1]!.commentsDic?[1])
    }
  }
  
  func test_cancelEditIssue() {
    LocalDataManager.shared.setRepoList(repoList: TestData().repoListWithComment)
    
    let before = try! LocalDataManager.shared.getProvider().toBlocking().first()
    
    let viewModel = createViewModel(issue: Issue.test, issueIndex: 0, repoIndex: 0)
    viewModel.cancelEditIssue()
    
    let after = try! LocalDataManager.shared.getProvider().toBlocking().first()
    
    XCTAssertEqual(before![0].issuesDic![1], after![0].issuesDic![1])
    XCTAssertEqual(before![0].issuesDic![1], Issue.test)
  }
  
  func test_cancelEditComment() {
    LocalDataManager.shared.setRepoList(repoList: TestData().repoListWithComment)
    
    let before = try! LocalDataManager.shared.getProvider().toBlocking().first()
    
    let viewModel = createViewModel(issue: Issue.test, issueIndex: 0, repoIndex: 0)
    viewModel.cancelEditComment(newComment: TestData().comment)
    
    let after = try! LocalDataManager.shared.getProvider().toBlocking().first()
    
    let aComment = before![0].issuesDic![1]?.commentsDic![1]
    let bComment = after![0].issuesDic![1]?.commentsDic![1]
    XCTAssertEqual(aComment, bComment)
  }
}
