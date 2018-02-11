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
  let issueApi: IssueServiceRepresentable
  let statusDriver: Driver<AuthService.Status>
  
  //output
  let repoList = BehaviorRelay<[Repository]>(value: [])
  let running = LocalDataManager.shared.running
  
  init(issueApi: IssueServiceRepresentable = IssueService(),
       statusDriver: Driver<AuthService.Status> = AuthService().status) {
    self.statusDriver = statusDriver
    self.issueApi = issueApi
    bindOutput()
  }
  
  func bindOutput() {
    
    //내 정보 받아오기 성공하면 내 이슈 몽땅 로컬로 가져오기
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
    
    //로컬데이터로부터 레퍼지토리 가져와서 바인딩
    LocalDataManager.shared.getProvider()
      .map { $0.filter { $0.value.issuesDic!.count > 0 } }
      .map({ (repoDict) -> [Repository] in
        return Array(repoDict.values)
          .sorted(by: { $0.created_at > $1.created_at })
      })
      .asDriver(onErrorJustReturn: [])
      .drive(repoList)
      .disposed(by: bag)
    
  }
}
