//
//  RawDataSource.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 25..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RawDataSource {
  static let shared: RawDataSource = RawDataSource()
  private let bag = DisposeBag()
  
  //local
  var allIssuesProvider = Variable<[Issue]>([])
  var tempRepoListProvider = Variable<[RepositoryUI]>([])
  var allIssueUIProvider = Variable<[IssueUI]>([])
  
  //모든 이슈 가져오기
  func bindAllIssues(filter: IssueService.Filter, state: IssueService.State, sort: IssueService.Sort) {
    IssueService.currentPage.asObservable()
      .flatMap { (page) in
        IssueService.fetchAllIssues(filter: .all, state: .open, sort: .created, page: page)
      }.asDriver(onErrorJustReturn: [])
      .do(onNext: { [weak self] (issueArr) in
        for issue in issueArr {
          self?.allIssuesProvider.value.append(issue)
        }
      })
      .drive()
      .disposed(by: bag)
  }
  
  //모든 이슈로부터 레퍼지토리 리스트 추출하기
  func getTempRepoUIListFromIssueArr() {
    allIssuesProvider.asObservable()
      .map { (issues) -> [Repository] in
        issues
          .map { $0.repository! }
          .filter { $0.open_issues > 0 }
      }
      .catchErrorJustReturn([])
      .map({ repoArr -> [Repository] in
        return Array(Set(repoArr))
      })
      .map { (repos) in
        repos.map { RepositoryUI(id: $0.id, name: $0.name, issueArr: nil, created: $0.created_at) }
      }.asDriver(onErrorJustReturn: [])
      .drive(tempRepoListProvider)
      .disposed(by: bag)
  }
  
  //모든 이슈를 사용자이슈로 변형하기
  func bindIssueUI() {
    allIssuesProvider.asDriver()
      .map { [weak self] arr in
        (self?.convertIssueToIssueUI(issueArr: arr))!
      }
      .drive(allIssueUIProvider)
      .disposed(by: bag)
  }
  
  //해당 레퍼지토리에 사용자이슈 넣기
  func inputIssueUIToRepoUI() {
    tempRepoListProvider.asDriver()
      .map({ [weak self] repoUIList -> [RepositoryUI] in
        var resultList = [RepositoryUI]()
        
        for repoUI in repoUIList {
          var issueUIArr = [IssueUI]()
          
          for issueUI in (self?.allIssueUIProvider.value)! {
            if repoUI.id == issueUI.repoId {
              issueUIArr.append(issueUI)
            }
          }
          
          let newRepoUI = RepositoryUI(id: repoUI.id, name: repoUI.name, issueArr: issueUIArr, created: repoUI.created)
          resultList.append(newRepoUI)
        }
        
        return resultList
      })
      .asDriver(onErrorJustReturn: [])
      .drive(TableViewDataSource.shared.resultProvider)
      .disposed(by: bag)
  }
  
  //helper
  func convertIssueToIssueUI(issueArr: [Issue]) -> [IssueUI] {
    var arr = [IssueUI]()
    for issue in issueArr {
      let newIssue = IssueUI(title: issue.title, body: issue.body, created: issue.created_at, repoId: (issue.repository?.id)!)
      arr.append(newIssue)
    }
    return arr
  }
  
  //이슈생성 api 요청하기
  func requestCreateIssue(title: String,
                   comment: String,
                   label: [IssueService.Label],
                   repo: Repository) -> Observable<Bool> {
    return IssueService.createIssue(title: title,
                                    comment: comment,
                                    label: label,
                                    repo: repo)
      .do(onNext: { [weak self] (newIssue) in
        self?.allIssuesProvider.value.append(newIssue)
      })
      .map { (issue) -> Bool in
        if issue.title != "" {
          return true
        }
        return false
      }.catchErrorJustReturn(false)
  }
  
  //이슈 편집 api 요청하기
  func requestEditIssue(title: String,
                 comment: String,
                 label: [IssueService.Label],
                 issue: Issue,
                 state: IssueService.State) -> Observable<Bool> {
    return IssueService.editIssue(title: title, comment: comment, label: label, issue: issue, state: state)
      .asObservable()
      .do(onNext: { [weak self] issue in
        switch state {
        case .closed: do {
          self?.allIssuesProvider.value = (self?.allIssuesProvider.value.filter { $0.number != issue.number })!
          }
        case .open: do {
          self?.changeLocalWhenIssueUpdated(issue: issue)
          }
        default: break
        }
      })
      .map { (issue) -> Bool in
        if issue.title != "" {
          return true
        }
        return false
      }.catchErrorJustReturn(false)
  }
  
  func changeLocalWhenIssueUpdated(issue: Issue) {
    var index: Int = -1
    for i in 0..<allIssuesProvider.value.count {
      if allIssuesProvider.value[i].id == issue.id {
        index = i
      }
    }
    if index != -1 {
      allIssuesProvider.value[index] = issue
    }
  }
}
