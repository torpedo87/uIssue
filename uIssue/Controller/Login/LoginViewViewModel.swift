//
//  LoginViewViewModel.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 19..
//  Copyright © 2018년 samchon. All rights reserved.
//

import RxSwift
import RxCocoa

class LoginViewViewModel {
  
  //input
  let idTextInput = Variable<String>("")
  let pwdTextInput = Variable<String>("")
  let authApi: AuthServiceRepresentable
  
  //output
  let validate: Driver<Bool>
  
  //api 의존성 주입을 위해 프로토콜 사용
  init(authApi: AuthServiceRepresentable = AuthService()) {
    self.authApi = authApi
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
  
  func requestLogin(id: String, password: String) -> Observable<AuthService.Status> {
    return authApi.requestToken(userId: id, userPassword: password)
  }
  
}
