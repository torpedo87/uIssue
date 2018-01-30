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
  let authApiType: AuthServiceRepresentable.Type
  let issueApiType: IssueServiceRepresentable.Type
  
  init(authApiType: AuthServiceRepresentable.Type = AuthService.self, issueApiType: IssueServiceRepresentable.Type = IssueService.self) {
    self.authApiType = authApiType
    self.issueApiType = issueApiType
    bindOutput()
  }
  
  func bindOutput() {
    authApiType.status.asObservable()
      .subscribe(onNext: { [weak self] status in
        if status == .authorized {
          LocalDataManager(apiType: (self?.issueApiType)!)
        }
      }).disposed(by: bag)
    
    LocalDataManager.shared.provider()
      .asDriver(onErrorJustReturn: [])
      .drive(repoList)
      .disposed(by: bag)
    
    LocalDataManager.shared.provider()
      .asDriver(onErrorJustReturn: [])
      .map { _ in false }
      .drive(running)
      .disposed(by: bag)
  }
  
  
  
}
