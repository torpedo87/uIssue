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
  var tempRepoListProvider = Variable<[Repository]>([])
  
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
      .asDriver(onErrorJustReturn: [])
      .drive(tempRepoListProvider)
      .disposed(by: bag)
  }
  
  //해당 레퍼지토리에 이슈Dic 넣기
  func inputIssueToRepo() {
    tempRepoListProvider.asDriver()
      .map({ [weak self] repoList -> [Repository] in
        var resultList = [Repository]()
        
        for repo in repoList {
          var issueArr = [Issue]()
          
          for issue in (self?.allIssuesProvider.value)! {
            if repo.id == issue.repository?.id {
              issueArr.append(issue)
            }
          }
          
          var newRepo = repo
          newRepo.setIssuesDic(issueArr: issueArr)
          resultList.append(newRepo)
        }
        
        return resultList
      })
      .asDriver(onErrorJustReturn: [])
      .debug("-------------issuedic--------------")
      .drive(TableViewDataSource.shared.resultProvider)
      .disposed(by: bag)
  }
  
  
  //이슈생성 api 요청하기
  func requestCreateIssue(title: String,
                   comment: String,
                   label: [IssueService.Label],
                   repo: Repository) -> Observable<Issue> {
    return IssueService.createIssue(title: title,
                                    comment: comment,
                                    label: label,
                                    repo: repo)
      .catchError({ (error) -> Observable<Issue> in
        return Observable.empty()
      })
      
  }
  
  //이슈 편집 api 요청하기
  func requestEditIssue(title: String,
                 comment: String,
                 label: [IssueService.Label],
                 issue: Issue,
                 state: IssueService.State,
                 repo: Repository) -> Observable<Issue> {
    return IssueService.editIssue(title: title, comment: comment, label: label, issue: issue, state: state, repo: repo)
      .catchError({ (error) -> Observable<Issue> in
        return Observable.empty()
      })
  }
  
}
