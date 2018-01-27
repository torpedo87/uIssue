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
  
  //이슈생성 api요청 성공하면 로컬 변경하기
  func createIssue(title: String, comment: String) -> Observable<Bool> {
    return APIDataManager.shared.requestCreateIssue(title: title, comment: comment, label: [.enhancement], repo: selectedRepo)
      .map({ [weak self] (newIssue) -> Bool in
        if newIssue.id != -1 {
          LocalDataManager.shared.changeLocalWhenIssueCreated(newIssue: newIssue, repoIndex: (self?.repoIndex)!)
          return true
        }
        return false
      })
  }
}
