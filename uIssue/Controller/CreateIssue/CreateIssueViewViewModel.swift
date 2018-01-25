//
//  CreateIssueViewViewModel.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 23..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CreateIssueViewViewModel {
  
  //input
  let titleInput = Variable<String>("")
  //output
  let validate: Driver<Bool>
  var selectedRepo: Repository!
  var repoIndex: Int!
  
  init(repo: Repository, repoIndex: Int) {
    self.repoIndex = repoIndex
    selectedRepo = repo
    validate = titleInput.asObservable()
      .map { (text) -> Bool in
        if text.isEmpty {
          return false
        }
        return true
    }.asDriver(onErrorJustReturn: false)
    
  }
  
  func requestCreateIssue(title: String, comment: String, label: [IssueService.Label]) -> Observable<Bool> {
    
    return TableViewDataSource.shared.createIssue(title: title, comment: comment, repoIndex: repoIndex)
  }
}
