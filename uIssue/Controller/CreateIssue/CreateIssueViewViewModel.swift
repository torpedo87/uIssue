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
  var selectedRepo: RepositoryUI!
  var repoIndex: Int!
  
  init(repo: RepositoryUI, repoIndex: Int) {
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
  
  func requestCreateIssue(title: String, comment: String, label: [IssueService.Label]) {
    let newIssue = IssueUI(title: title, body: comment, created: "created", repoId: selectedRepo.id)
    TableViewDataSource.shared.createLocalIssue(issue: newIssue, repoIndex: repoIndex)
  }
}
