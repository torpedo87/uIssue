//
//  AuthService.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 27..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

//for test
protocol AuthServiceRepresentable {
  var status: Driver<AuthService.Status> { get }
  func requestToken(userId: String, userPassword: String) -> Observable<AuthService.Status>
  func removeToken(userId: String, userPassword: String) -> Observable<AuthService.Status>
}

class AuthService: AuthServiceRepresentable {
  
  enum Errors: Error {
    case requestFail
    case invalidUserInfo
  }
  
  enum Status {
    case authorized
    case unAuthorized(String)
    
    //for test
    static func ==(lhs: Status, rhs: Status) -> Bool {
      switch (lhs, rhs) {
      case (.authorized, .authorized): return true
      case (.authorized, .unAuthorized): return false
      case (.unAuthorized, .unAuthorized): return true
      case (.unAuthorized, .authorized): return false
      }
    }
  }
  
  var status: Driver<Status> {
    return Observable.create { observer in
      if let _ = UserDefaults.loadToken() {
        observer.onNext(.authorized)
      } else {
        observer.onNext(.unAuthorized("caanot load token"))
      }
      return Disposables.create()
    }.asDriver(onErrorJustReturn: Status.unAuthorized("unAuthorized"))
  }
  
  func requestToken(userId: String, userPassword: String) -> Observable<Status> {
    
    guard let url =
      URL(string: "https://api.github.com/authorizations") else { fatalError() }
    
    let request: Observable<URLRequest> = Observable.create{ observer in
      let request: URLRequest = {
        var request = URLRequest(url: $0)
        let userInfoString = userId + ":" + userPassword
        guard let userInfoData =
          userInfoString.data(using: String.Encoding.utf8) else { fatalError() }
        let base64EncodedCredential = userInfoData.base64EncodedString()
        let authString = "Basic \(base64EncodedCredential)"
        request.httpMethod = "POST"
        request.addValue(authString, forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let bodyObject: [String: Any] = [
          "scopes": [
            "public_repo"
          ],
          "note": UUID().uuidString
        ]
        
        request.httpBody =
          try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
          
        return request
      }(url)
      
      observer.onNext(request)
      observer.onCompleted()
      return Disposables.create()
    }
    
    return request.flatMap{
      URLSession.shared.rx.response(request: $0)
    }
      .map({ (response, data) -> Status in
        if 200 ..< 300 ~= response.statusCode {
          let token = try! JSONDecoder().decode(Token.self, from: data)
          UserDefaults.saveToken(token: token)
          return Status.authorized
        } else if 401 == response.statusCode {
          throw Errors.invalidUserInfo
        } else {
          throw Errors.requestFail
        }
      })
      .catchError({ (error) -> Observable<Status> in
        if let error = error as? Errors {
          switch error {
          case .requestFail:
            return Observable.just(Status.unAuthorized("requestFail"))
          case .invalidUserInfo:
            return Observable.just(Status.unAuthorized("invalidUserInfo"))
          }
        }
        return Observable.just(Status.unAuthorized(error.localizedDescription))
      })
    
  }
  
  func removeToken(userId: String, userPassword: String) -> Observable<Status> {
    guard let tokenId = UserDefaults.loadToken()?.id else { fatalError() }
    guard let url =
      URL(string: "https://api.github.com/authorizations/\(tokenId)") else { fatalError() }
    
    let request: Observable<URLRequest> = Observable.create { (observer) -> Disposable in
      let request: URLRequest = {
        var request = URLRequest(url: $0)
        let userInfoString = userId + ":" + userPassword
        guard let userInfoData =
          userInfoString.data(using: String.Encoding.utf8) else { fatalError() }
        let base64EncodedCredential = userInfoData.base64EncodedString()
        let authString = "Basic \(base64EncodedCredential)"
        request.httpMethod = "DELETE"
        request.addValue(authString, forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        return request
      }(url)
      
      observer.onNext(request)
      observer.onCompleted()
      return Disposables.create()
    }
    
    return request.flatMap({
      URLSession.shared.rx.response(request: $0)
    })
      .map({ (response, data) -> Status in
        if 200..<300 ~= response.statusCode {
          UserDefaults.removeLocalToken()
          return Status.authorized
        } else if 401 == response.statusCode {
          throw Errors.invalidUserInfo
        } else {
          throw Errors.requestFail
        }
      })
      .catchError({ (error) -> Observable<AuthService.Status> in
        if let error = error as? Errors {
          switch error {
          case .requestFail:
            return Observable.just(Status.unAuthorized("requestFail"))
          case .invalidUserInfo:
            return Observable.just(Status.unAuthorized("invalidUserInfo"))
          }
        }
        return Observable.just(Status.unAuthorized(error.localizedDescription))
      })
  }
  
  
}
