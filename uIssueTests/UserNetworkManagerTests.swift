//
//  UserNetworkManagerTests.swift
//  uIssueTests
//
//  Created by junwoo on 2018. 1. 23..
//  Copyright © 2018년 samchon. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
import RxBlocking
@testable import uIssue

class UserNetworkManagerTests: XCTestCase {
  var scheduler: ConcurrentDispatchQueueScheduler!
  var userId: String!
  var userPassword: String!
  
  override func setUp() {
    super.setUp()
    scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
    let userInfo = getUserInfoFromTxt()
    userId = userInfo.0
    userPassword = userInfo.1
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testRequestTokenAndRemoveToken() {
    let loginResult = UserNetworkManager.requestToken(userId: userId, userPassword: userPassword).subscribeOn(scheduler)

    do {
      guard let result = try loginResult.toBlocking(timeout: 5.0).first() else { return }
      XCTAssertTrue(result == UserNetworkManager.Status.authorized)
    } catch {
      XCTFail(error.localizedDescription)
    }
    
    let logoutResult = UserNetworkManager.removeToken(userId: userId, userPassword: userPassword).subscribeOn(scheduler)
    
    do {
      guard let result = try logoutResult.toBlocking(timeout: 5.0).first() else { return }
      XCTAssertTrue(result == UserNetworkManager.Status.authorized)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }
  
  func getUserInfoFromTxt() -> (String, String) {
    let bundle = Bundle(for: UserNetworkManagerTests.self)
    var contents = ""
    if let filepath = bundle.path(forResource: "userInfo", ofType: "txt") {
      do {
        contents = try String(contentsOfFile: filepath)
      } catch {
        // contents could not be loaded
      }
    } else {
      // example.txt not found!
    }
    let arr = contents.components(separatedBy: ",")
    print("arr", arr)
    return (arr[0], arr[1])
  }
  
}
