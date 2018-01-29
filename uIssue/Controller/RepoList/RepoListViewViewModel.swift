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
  
  
  init() {
    LocalDataManager()
    
    bindOutput()
  }
  
  func bindOutput() {
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
  
  func sortByCreated() {
    repoList.value = repoList.value.sorted(by: { $0.created_at.compare($1.created_at) == .orderedDescending })
  }
  
}
