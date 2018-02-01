//
//  SettingViewViewModel.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 22..
//  Copyright © 2018년 samchon. All rights reserved.
//

import RxSwift
import RxCocoa

class SettingViewViewModel {
  
  //input
  let idTextInput = Variable<String>("")
  let pwdTextInput = Variable<String>("")
  
  //output
  let validate: Driver<Bool>
  
  init() {
    
    let isIdValid = idTextInput.asObservable()
      .map { (text) -> Bool in
        if text.isEmpty {
          return false
        }
        return true
    }
    
    let isPwdValid = pwdTextInput.asObservable()
      .map { (text) -> Bool in
        if text.isEmpty {
          return false
        }
        return true
    }
    
    validate = Observable.combineLatest(isIdValid, isPwdValid)
      .map{ tuple -> Bool in
        if tuple.0 == true && tuple.1 == true {
          return true
        }
        return false
      }
      .asDriver(onErrorJustReturn: false)
    
  }
  
  func requestLogout(id: String, password: String) -> Observable<AuthService.Status> {
    return AuthService().removeToken(userId: id, userPassword: password)
  }
  
}

