//
//  UserNetworkManager.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 27..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation
import RxSwift

class UserNetworkManager {
  
  enum Errors: Error {
    case requestFail
    case invalidUserInfo
  }
  
  enum Status {
    case authorizable
    case unAuthorizable
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
        
        do {
          request.httpBody = try JSONSerialization.data(withJSONObject: bodyObject, options: [])
        } catch {
          debugPrint(error.localizedDescription)
        }
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
          UserDefaults.standard.saveToken(token: token)
          return Status.authorizable
        } else if 401 == response.statusCode {
          throw Errors.invalidUserInfo
        } else {
          throw Errors.requestFail
        }
      })
      .catchError({ (error) -> Observable<Status> in
        return Observable.just(Status.unAuthorizable)
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
