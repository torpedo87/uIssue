//
//  RepoListViewViewModel.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 20..
//  Copyright © 2018년 samchon. All rights reserved.
//

import RxSwift
import RxCocoa


class RepoListViewViewModel {
  private let bag = DisposeBag()
  
  //output
  let repoList = Variable<[Repository]>([])
  private var loginStatus: Driver<UserNetworkManager.Status>
  
  init() {
    loginStatus = UserNetworkManager.status
    bindOutput()
  }
  
  func bindOutput() {
    
    loginStatus.asObservable()
      .flatMap({ (status) -> Observable<[Repository]> in
        switch status {
        case .authorized:
          return IssueDataManager.fetchRepoList(sort: .created)
        default: return Observable.just([Repository]())
        }
      })
      .bind(to: repoList)
      .disposed(by: bag)
  }
  
  func makeIssueListViewModel(for index: Int) -> IssueListViewViewModel {
    return IssueListViewViewModel(repo: repoList.value[index])
  }
  
}
