//
//  IssueListViewViewModel.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 20..
//  Copyright © 2018년 samchon. All rights reserved.
//

import RxSwift
import RxCocoa


class IssueListViewViewModel {
  private let bag = DisposeBag()
  
  //input
  var selectedRepo: Repository!
  
  //output
  let issueList = Variable<[Issue]>([])
  //var loggedIn: Driver<UserNetworkManager.Status>
  
  init(repo: Repository) {
    selectedRepo = repo
    //loggedIn = UserNetworkManager.status
    requestFetchIssueList()
    bindOutput()
  }
  
  func bindOutput() {
    
    DataProvider.shared.issueListProvider
      .asDriver()
      .drive(issueList)
      .disposed(by: bag)
    
//    loggedIn.asObservable()
//      .flatMap({ [weak self] (status) -> Observable<[Issue]> in
//        switch status {
//        case .authorized:
//          return IssueDataManager.fetchIssueListForRepo(repo: (self?.selectedRepo)!,
//                                                        sort: IssueDataManager.Sort.created,
//                                                        state: IssueDataManager.State.open)
//        default: return Observable.just([Issue]())
//        }
//
//      })
//      .bind(to: issueList)
//      .disposed(by: bag)
  }
  
  func requestFetchIssueList() {
    DataProvider.shared.fetchIssueList(repo: selectedRepo, sort: .created, state: .open)
  }
}


