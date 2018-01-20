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
  private(set) var loggedIn: Driver<UserNetworkManager.Status>
  
  init() {
    loggedIn = UserNetworkManager.status
    bindOutput()
  }
  
  func bindOutput() {
    
    loggedIn.asObservable()
      .flatMap({ (status) -> Observable<[Repository]> in
        if status == UserNetworkManager.Status.authorized {
          return IssueDataManager.fetchRepoList(sort: IssueDataManager.Sort.created.rawValue)
        }
        return Observable.just([Repository]())
      })
      .bind(to: repoList)
      .disposed(by: bag)
  }
  
}
