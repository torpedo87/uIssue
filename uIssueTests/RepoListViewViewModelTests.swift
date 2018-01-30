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
  var scheduler: ConcurrentDispatchQueueScheduler!
  
  override func setUp() {
    super.setUp()
    viewModel = RepoListViewViewModel()
    scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
}
