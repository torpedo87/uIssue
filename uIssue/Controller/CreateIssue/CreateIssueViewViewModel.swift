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

struct Property {
  var labels: [IssueService.Label]
  var assignees: [User]
}

class CreateIssueViewViewModel {
  private let bag = DisposeBag()
  //input
  let titleInput = Variable<String>("")
  //output
  let validate: Driver<Bool>
  private let repoId: Int!
  let issueApi: IssueServiceRepresentable
  let selectedRepo: Repository!
  let assignees = Variable<[User]>([])
  let labels = Variable<[IssueService.Label]>(IssueService.Label.arr)
  var labelDict = [Int:IssueService.Label]()
  var userDict = [Int:User]()
  
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
    
    
    issueApi.getAssignees(repo: selectedRepo)
      .asDriver(onErrorJustReturn: [])
      .debug()
      .drive(assignees)
      .disposed(by: bag)
  }
  
  //이슈생성 api요청 성공하면 로컬 변경하기
  func createIssue(title: String, newComment: String, label: [IssueService.Label], users: [User]) -> Observable<Bool> {
    let repoId = self.repoId!
    return issueApi.createIssue(title: title, body: newComment, label: label, repo: selectedRepo, users: users)
      .map({ (newIssue) -> Bool in
        if newIssue.id != -1 {
          LocalDataManager.shared.createIssue(repoId: repoId, createdIssue: newIssue)
          return true
        }
        return false
      })
  }
}
