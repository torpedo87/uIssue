//
//  UserNetworkManager.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 27..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class UserNetworkManager {
  
  enum Errors: Error {
    case requestFail
    case invalidUserInfo
  }
  
  enum Status {
    case authorized
    case unAuthorized(String)
  }
  
  static var status: Driver<Status> {
    return Observable.create { observer in
      if let _ = UserDefaults.loadToken() {
        observer.onNext(.authorized)
      } else {
        observer.onNext(.unAuthorized("caanot load token"))
      }
      return Disposables.create()
    }.asDriver(onErrorJustReturn: Status.unAuthorized("unAuthorized"))
  }
  
  static func requestToken(userId: String, userPassword: String) -> Observable<Status> {
    
    guard let url = URL(string: "https://api.github.com/authorizations") else { fatalError() }
    
    //rx 는 시퀀스이므로 request부터 Observable 형태로 감시하는 건가보다
    //Observable<URLRequest>
    let request: Observable<URLRequest> = Observable.create{ observer in
      let request: URLRequest = {
        var request = URLRequest(url: $0)
        let userInfoString = userId + ":" + userPassword
        guard let userInfoData = userInfoString.data(using: String.Encoding.utf8) else { fatalError() }
        let base64EncodedCredential = userInfoData.base64EncodedString()
        let authString = "Basic \(base64EncodedCredential)"
        request.httpMethod = "POST"
        request.addValue(authString, forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let bodyObject: [String: Any] = [
          "scopes": [
            "public_repo"
          ],
          "note": "admin uIssue"
        ]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
          
        return request
      }(url)
      
      observer.onNext(request)
      observer.onCompleted()
      return Disposables.create()
    }
    
    //flatmap을 사용하면 그 다음 연산자에 observable을 벗긴채로 전달 가능한건가보다
    //O<request> -> flatmap -> O<(response, data)>
    return request.flatMap{
      URLSession.shared.rx.response(request: $0)
    }
      //O<(response, data)> -> map -> O<status>
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
        return Observable.just(Status.unAuthorized(error.localizedDescription))
      })
    
  }
  
  static func removeToken(userId: String, userPassword: String) -> Observable<Status> {
    guard let tokenId = UserDefaults.loadToken()?.id else { fatalError() }
    guard let url = URL(string: "https://api.github.com/authorizations/\(tokenId)") else { fatalError() }
    
    let request: Observable<URLRequest> = Observable.create { (observer) -> Disposable in
      let request: URLRequest = {
        var request = URLRequest(url: $0)
        let userInfoString = userId + ":" + userPassword
        guard let userInfoData = userInfoString.data(using: String.Encoding.utf8) else { fatalError() }
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
      .catchError({ (error) -> Observable<UserNetworkManager.Status> in
        return Observable.just(Status.unAuthorized(error.localizedDescription))
      })
  }
}
