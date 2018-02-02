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
  private let repoId: Int!
  let issueApi: IssueServiceRepresentable
  let selectedRepo: Repository!
  
  init(repoId: Int, issueApi: IssueServiceRepresentable = IssueService()) {
    self.issueApi = issueApi
    self.repoId = repoId
    self.selectedRepo = LocalDataManager.shared.getRepo(repoId: repoId)
    
    validate = titleInput.asObservable()
      .map { (text) -> Bool in
        if text.isEmpty {
          return false
        }
        return true
    }.asDriver(onErrorJustReturn: false)
    
  }
  
  //이슈생성 api요청 성공하면 로컬 변경하기
  func createIssue(title: String, newComment: String) -> Observable<Bool> {
    let repoId = self.repoId!
    return issueApi.createIssue(title: title, comment: newComment, label: [.enhancement], repo: selectedRepo)
      .map({ (newIssue) -> Bool in
        if newIssue.id != -1 {
          LocalDataManager.shared.createIssue(repoId: repoId, createdIssue: newIssue)
          return true
        }
        return false
      })
  }
}
