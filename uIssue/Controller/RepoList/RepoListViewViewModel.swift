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
  let repoList = BehaviorRelay<[Repository]>(value: [])
  let running = BehaviorRelay<Bool>(value: true)
  let issueApi: IssueServiceRepresentable
  let statusDriver: Driver<AuthService.Status>
  
  init(issueApi: IssueServiceRepresentable = IssueService(),
       statusDriver: Driver<AuthService.Status> = AuthService().status) {
    self.statusDriver = statusDriver
    self.issueApi = issueApi
    bindOutput()
  }
  
  func bindOutput() {
    
    statusDriver.asObservable()
      .flatMap({ [weak self] (status) -> Observable<Bool> in
        if status == .authorized {
          return (self?.issueApi)!.getUser()
        }
        return Observable.just(false)
      })
      .asDriver(onErrorJustReturn: false)
      .drive(onNext: { [weak self] bool in
        if bool {
          LocalDataManager.shared.bindOutput(issueApi: (self?.issueApi)!)
        }
      })
      .disposed(by: bag)
    
    LocalDataManager.shared.getProvider()
      .map { $0.filter { $0.value.issuesDic!.count > 0 } }
      .map({ (repoDict) -> [Repository] in
        return Array(repoDict.values)
          .sorted(by: { $0.created_at > $1.created_at })
      })
      .asDriver(onErrorJustReturn: [])
      .drive(repoList)
      .disposed(by: bag)
    
    repoList.asDriver()
      .map { _ in false }
      .drive(running)
      .disposed(by: bag)
    
  }
  
}
