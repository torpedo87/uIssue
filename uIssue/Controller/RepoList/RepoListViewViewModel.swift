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
  let running = Variable<Bool>(true)
  let issueApi: IssueServiceRepresentable
  let statusDriver: Driver<AuthService.Status>
  
  init(issueApi: IssueServiceRepresentable = IssueService(),
       statusDriver: Driver<AuthService.Status> = AuthService().status) {
    self.statusDriver = statusDriver
    self.issueApi = issueApi
    bindOutput()
  }
  
  func bindOutput() {
    
    statusDriver
      .drive(onNext: { [weak self] status in
        if status == .authorized {
          LocalDataManager.shared.bindOutput(issueApi: (self?.issueApi)!)
        }
      })
      .disposed(by: bag)
    
    LocalDataManager.shared.getProvider()
      .map { $0.filter { $0.value.issuesDic!.count > 0 } }
      .map({ (repoDict) -> [Repository] in
        return Array(repoDict.values).sorted(by: { $0.created_at > $1.created_at })
      })
      .asDriver(onErrorJustReturn: [])
      .drive(repoList)
      .disposed(by: bag)
    
    repoList.asDriver()
      .map { _ in false }
      .drive(running)
      .disposed(by: bag)
  }
  
  func sortRepoListByCreated() {
    repoList.value = repoList.value.sorted(by: { $0.created_at > $1.created_at })
  }
}
