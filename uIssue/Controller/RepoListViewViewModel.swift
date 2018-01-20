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
  
  //input
  let account: Driver<UserNetworkManager.Status>
  
  //output
  let repoList = Variable<[Repository]>([])
  
  init(account: Driver<UserNetworkManager.Status>) {
    self.account = account
    bindOutput()
  }
  
  func bindOutput() {
    //observe the current account status
    let currentAccount = account
      .filter { account in
        switch account {
        case .authorized: return true
        default: return false
        }
      }
      .distinctUntilChanged()
    
    //fetch repo list
    currentAccount.asObservable()
      .flatMap {_ in
        IssueDataManager.fetchRepoList(sort: IssueDataManager.Sort.created.rawValue)
    }
      .bind(to: repoList)
      .disposed(by: bag)
  }
  
}
