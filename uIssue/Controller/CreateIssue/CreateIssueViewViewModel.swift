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
  
  init(repo: Repository) {
    selectedRepo = repo
    validate = titleInput.asObservable()
      .map { (text) -> Bool in
        if text.isEmpty {
          return false
        }
        return true
    }.asDriver(onErrorJustReturn: false)
    
  }
  
  func submitNewIssue(title: String, comment: String, label: [IssueDataManager.Label]) -> Observable<Issue> {
    return IssueDataManager.createIssue(title: title, comment: comment, label: label, repo: selectedRepo)
  }
}
