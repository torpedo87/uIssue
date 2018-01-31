//
//  LoginViewViewModelTests.swift
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

class LoginViewViewModelTests: XCTestCase {
  
  var viewModel: LoginViewViewModel!
  var scheduler: ConcurrentDispatchQueueScheduler!
  var userId: String!
  var userPassword: String!
  
  override func setUp() {
    super.setUp()
    viewModel = LoginViewViewModel()
    scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
    let userInfo = getUserInfoFromTxt()
    userId = userInfo.0
    userPassword = userInfo.1
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  //helper
  func getUserInfoFromTxt() -> (String, String) {
    let bundle = Bundle(for: LoginViewViewModelTests.self)
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
  
  func testRequestLoginWithValidUserInfo() {
    
    //이미 로그인된 경우
    if let _ = UserDefaults.loadToken() {
      let loginResult = viewModel.requestLogin(id: userId, password: userPassword).subscribeOn(scheduler)
      do {
        guard let result = try loginResult.toBlocking(timeout: 5.0).first() else { return }
        XCTAssertTrue(result == AuthService.Status.unAuthorized("requestFail"))
      } catch {
        XCTFail(error.localizedDescription)
      }
      
      let logoutResult = AuthService().removeToken(userId: userId, userPassword: userPassword).subscribeOn(scheduler)
      do {
        guard let result = try logoutResult.toBlocking(timeout: 5.0).first() else { return }
        XCTAssertTrue(result == AuthService.Status.authorized)
      } catch {
        XCTFail(error.localizedDescription)
      }
      
    //로그인 되어 있지 않은 경우
    } else {
      let loginResult = viewModel.requestLogin(id: userId, password: userPassword).subscribeOn(scheduler)
      do {
        guard let result = try loginResult.toBlocking(timeout: 5.0).first() else { return }
        XCTAssertTrue(result == AuthService.Status.authorized)
      } catch {
        XCTFail(error.localizedDescription)
      }
      
      let logoutResult = AuthService().removeToken(userId: userId, userPassword: userPassword).subscribeOn(scheduler)
      do {
        guard let result = try logoutResult.toBlocking(timeout: 5.0).first() else { return }
        XCTAssertTrue(result == AuthService.Status.authorized)
      } catch {
        XCTFail(error.localizedDescription)
      }
    }
    
  }
  
}
