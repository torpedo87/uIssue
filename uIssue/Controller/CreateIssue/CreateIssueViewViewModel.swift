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

class CreateIssueViewViewModel: PropertySettable {
  private let bag = DisposeBag()
  
  //input
  private let repoId: Int!
  let titleInput = BehaviorRelay<String>(value: "")
  let issueApi: IssueServiceRepresentable
  let selectedRepo: Repository!
  
  //output
  let validate: Driver<Bool>
  let labelItemsDict =
    BehaviorRelay<[String:LabelItem]>(value: [String:LabelItem]())
  let assigneeItemsDict =
    BehaviorRelay<[String:AssigneeItem]>(value: [String:AssigneeItem]())
  
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
    
    bindOutput(repoId: repoId)
  }
  
  func bindOutput(repoId: Int) {
    //레퍼지토리 assignees 가져와서 바인딩
    LocalDataManager.shared.getProvider()
      .asDriver(onErrorJustReturn: [Int : Repository]())
      .map({ (dict) -> [User] in
        let repo = dict[repoId]
        if let _ = repo?.assigneesDic {
          return Array(repo!.assigneesDic!.values)
        } else {
          return []
        }
      })
      .map({ (users) -> [String:AssigneeItem] in
        return IssuePropertyItemService().changeAssigneeArrToDict(arr: users)
      })
      .asDriver(onErrorJustReturn: [String:AssigneeItem]())
      .drive(assigneeItemsDict)
      .disposed(by: bag)
    
    //라벨 바인딩
    Observable.just(IssueService.Label.arr)
      .map { (labels) -> [String:LabelItem] in
        return IssuePropertyItemService().changeLabelArrToDict(arr: labels)
      }
      .asDriver(onErrorJustReturn: [String : LabelItem]())
      .drive(labelItemsDict)
      .disposed(by: bag)
  }
  
  //이슈생성 api요청 성공하면 로컬 변경하기
  func createIssue(title: String,
                   newComment: String,
                   label: [IssueService.Label],
                   users: [User]) -> Observable<Bool> {
    let repoId = self.repoId!
    return issueApi.createIssue(title: title,
                                body: newComment,
                                label: label,
                                repo: selectedRepo,
                                users: users)
      .map({ (newIssue) -> Bool in
        if newIssue.id != -1 {
          LocalDataManager.shared.createIssue(repoId: repoId,
                                              createdIssue: newIssue)
          return true
        }
        return false
      })
  }
}
