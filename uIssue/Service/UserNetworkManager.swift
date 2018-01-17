//
//  UserNetworkManager.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 27..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation
import RxSwift

enum Errors: Error {
  case requestFail
  case invalidUserInfo
}

enum Status: Equatable {
  case authorizable
  case unAuthorizable
  
  static func ==(lhs: Status, rhs: Status) -> Bool {
    switch (lhs, rhs) {
    case (.authorizable, .unAuthorizable): return false
    case (.authorizable , .authorizable): return true
    case (.unAuthorizable, .authorizable): return false
    case (.unAuthorizable, .unAuthorizable): return true
    }
  }
}

class UserNetworkManager: UserNetworkService {
  
  static let bag = DisposeBag()
  
  static func getToken(userId: String, userPassword: String) -> Single<Status> {
    
    let config = URLSessionConfiguration.default
    let userInfoString = userId + ":" + userPassword
    guard let userInfoData = userInfoString.data(using: String.Encoding.utf8) else { fatalError() }
    let base64EncodedCredential = userInfoData.base64EncodedString()
    let authString = "Basic \(base64EncodedCredential)"
    let session = URLSession(configuration: config)
    
    guard let url = URL(string: "https://api.github.com/authorizations") else { fatalError() }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue(authString, forHTTPHeaderField: "Authorization")
    request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    
    let bodyObject: [String: Any] = [
      "scopes": [
        "public_repo"
      ],
      "note": "admin uIssue"
    ]
    
    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: bodyObject, options: [])
    } catch {
      debugPrint(error.localizedDescription)
    }
    
    return Single<Status>.create(subscribe: { (observer) -> Disposable in
      let task = session.dataTask(with: request) { (data, response, error) in
        guard let response = response as? HTTPURLResponse else { return }
        if 200 ..< 300 ~= response.statusCode {
          if let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let dict = json as? [String:Any] {
            guard let tokenId = dict["id"] as? Int else { fatalError() }
            guard let token = dict["token"] as? String else { fatalError() }
            let newToken = Token(id: tokenId, token: token)
            UserDefaults.standard.saveToken(token: newToken)
              .subscribe(onCompleted: {
                observer(.success(Status.authorizable))
                return
              }, onError: { (error) in
                observer(.error(error))
                return
              })
              .disposed(by: bag)
          }
        } else if 401 == response.statusCode {
          observer(.error(Errors.invalidUserInfo))
          return
        } else {
          observer(.error(Errors.requestFail))
          return
        }
      }
      
      task.resume()
      return Disposables.create {
        task.cancel()
      }
    })
      .catchError({ (error) -> PrimitiveSequence<SingleTrait, Status> in
        return Observable.just(Status.unAuthorizable).asSingle()
      })
    
  }
  
//  static func logout(userId: String, userPassword: String, tokenId: Int, completion: @escaping (Int?) -> Void) {
//    let config = URLSessionConfiguration.default
//    let session = URLSession(configuration: config)
//
//    let userInfoString = userId + ":" + userPassword
//    guard let userInfoData = userInfoString.data(using: String.Encoding.utf8) else { return }
//    let base64EncodedCredential = userInfoData.base64EncodedString()
//    let authString = "Basic \(base64EncodedCredential)"
//
//    guard let url = URL(string: "https://api.github.com/authorizations/\(tokenId)") else { return }
//    var request = URLRequest(url: url)
//    request.httpMethod = "DELETE"
//    request.addValue(authString, forHTTPHeaderField: "Authorization")
//    request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//    
//    let task = session.dataTask(with: request) { (data, response, error) in
//      if error == nil {
//        if let response = response as? HTTPURLResponse {
//          let statusCode = response.statusCode
//          print("success code ", statusCode)
//          completion(statusCode)
//        }
//
//      } else {
//        print("error", error.debugDescription)
//        completion(nil)
//      }
//    }
//
//    task.resume()
//  }
}
