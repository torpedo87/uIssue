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
  
//  override func setUp() {
//    super.setUp()
//
//  }
//
//  override func tearDown() {
//    LocalDataManager.shared.removeAll()
//    super.tearDown()
//  }
//
//  func createViewModel(repoId: Int, issueId: Int) -> IssueDetailViewViewModel {
//    return IssueDetailViewViewModel(repoId: repoId, issueId: issueId, issueApi: TestAPIMock.shared)
//  }
//
//  func test_requestFetchComments_changeLocal() {
//    LocalDataManager.shared.setRepoDict(repoDict: TestData().repoDict)
//    DispatchQueue.main.async {
//      TestAPIMock.shared.commentArrObjects.onNext(TestData().commentsList)
//    }
//
//    let viewModel = createViewModel(repoId: 1, issueId: 1)
//    viewModel.requestFetchComments()
//
//    let result = try! LocalDataManager.shared.getProvider().skip(1).toBlocking().first()
//
//    XCTAssertNotNil(result![1]?.issuesDic![1]?.commentsDic)
//    XCTAssertEqual(result![1]?.issuesDic![1]?.commentsDic![1]?.body, "body1")
//  }
//
//  func test_editIssue_changeLocal() {
//    LocalDataManager.shared.setRepoDict(repoDict: TestData().repoDict)
//    DispatchQueue.main.async {
//      TestAPIMock.shared.issueObjects.onNext(TestData().editedIssue)
//    }
//
//    let viewModel = createViewModel(repoId: 1, issueId: 1)
//    let bool = try! viewModel.editIssue(state: IssueService.State.open, newTitleText: "newTitle", newCommentText: "newBody", label: [.enhancement]).toBlocking().first()
//
//    if bool! {
//      let result = try! LocalDataManager.shared.getProvider().toBlocking().first()
//      XCTAssertEqual(result![1]?.issuesDic![1]?.body, "edited")
//    } else {
//      XCTFail()
//    }
//  }
//
//  //구독이 남아있어서 에러남
//  func test_closeIssue_changeLocal() {
////    LocalDataManager.shared.setRepoDict(repoDict: TestData().repoDict)
////    DispatchQueue.main.async {
////      TestAPIMock.shared.issueObjects.onNext(TestData().editedIssue)
////    }
////    let viewModel = createViewModel(repoId: 1, issueId: 1)
////    let bool = try! viewModel.editIssue(state: IssueService.State.closed, newTitleText: "newTitle", newCommentText: "newBody", label: [.enhancement]).toBlocking().first()
////
////    if bool! {
////      let result = try! LocalDataManager.shared.getProvider().toBlocking().first()
////      XCTAssertEqual(result![1]?.issuesDic!.count, 0)
////    } else {
////      XCTFail()
////    }
//  }
//
//  func test_createComment_changeLocal() {
//    LocalDataManager.shared.setRepoDict(repoDict: TestData().repoDict)
//    DispatchQueue.main.async {
//      TestAPIMock.shared.commentObjects.onNext(TestData().comment)
//    }
//    let viewModel = createViewModel(repoId: 1, issueId: 1)
//    let bool = try! viewModel.createComment(newCommentBody: "new").toBlocking().first()
//
//    if bool! {
//      let result = try! LocalDataManager.shared.getProvider().toBlocking().first()
//      XCTAssertEqual(result![1]?.issuesDic![1]!.commentsDic?.count, 1)
//    } else {
//      XCTFail()
//    }
//  }
//
//  func test_editComment_changeLocal() {
//    LocalDataManager.shared.setRepoDict(repoDict: TestData().repoDictWithComment)
//
//    DispatchQueue.main.async {
//      TestAPIMock.shared.commentObjects.onNext(TestData().editedComment)
//    }
//    let viewModel = createViewModel(repoId: 1, issueId: 1)
//    let bool = try! viewModel.editComment(existingComment: Comment.test, newCommentText: "edited").toBlocking().first()
//
//    if bool! {
//      let result = try! LocalDataManager.shared.getProvider().toBlocking().first()
//      XCTAssertEqual(result![1]?.issuesDic![1]!.commentsDic?[1]?.body, "edited")
//    } else {
//      XCTFail()
//    }
//  }
//
//  func test_deleteComment_changeLocalWhenAPISucceed() {
//    LocalDataManager.shared.setRepoDict(repoDict: TestData().repoDictWithComment)
//    DispatchQueue.main.async {
//      TestAPIMock.shared.boolObjects.onNext(true)
//    }
//    let viewModel = createViewModel(repoId: 1, issueId: 1)
//    let bool = try! viewModel.deleteComment(existingComment: Comment.test).toBlocking().first()
//
//    if bool! {
//      let result = try! LocalDataManager.shared.getProvider().toBlocking().first()
//      XCTAssertNil(result![1]?.issuesDic![1]!.commentsDic?[1])
//    } else {
//      XCTFail()
//    }
//  }
//
//  func test_deleteComment_changeLocalWhenAPIFail() {
//    LocalDataManager.shared.setRepoDict(repoDict: TestData().repoDictWithComment)
//    DispatchQueue.main.async {
//      TestAPIMock.shared.boolObjects.onNext(false)
//    }
//    let viewModel = createViewModel(repoId: 1, issueId: 1)
//    let bool = try! viewModel.deleteComment(existingComment: Comment.test).toBlocking().first()
//
//    if bool! {
//      XCTFail()
//    } else {
//      let result = try! LocalDataManager.shared.getProvider().toBlocking().first()
//      XCTAssertNotNil(result![1]?.issuesDic![1]!.commentsDic?[1])
//    }
//  }
//  
//  func test_cancelEditIssue() {
//    LocalDataManager.shared.setRepoDict(repoDict: TestData().repoDictWithComment)
//
//    let before = try! LocalDataManager.shared.getProvider().toBlocking().first()
//
//    let viewModel = createViewModel(repoId: 1, issueId: 1)
//    viewModel.cancelEditIssue()
//
//    let after = try! LocalDataManager.shared.getProvider().toBlocking().first()
//
//    XCTAssertEqual(before![1]?.issuesDic![1], after![1]?.issuesDic![1])
//    XCTAssertEqual(before![1]?.issuesDic![1], Issue.test)
//  }
//
//  func test_cancelEditComment() {
//    LocalDataManager.shared.setRepoDict(repoDict: TestData().repoDictWithComment)
//
//    let before = try! LocalDataManager.shared.getProvider().toBlocking().first()
//
//    let viewModel = createViewModel(repoId: 1, issueId: 1)
//    viewModel.cancelEditComment(existingComment: TestData().comment)
//
//    let after = try! LocalDataManager.shared.getProvider().toBlocking().first()
//
//    let aComment = before![1]?.issuesDic![1]?.commentsDic![1]
//    let bComment = after![1]?.issuesDic![1]?.commentsDic![1]
//    XCTAssertEqual(aComment, bComment)
//  }
}
