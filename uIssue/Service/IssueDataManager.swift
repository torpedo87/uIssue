//
//  IssueDataManager.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation
import RxSwift

class IssueDataManager {
  
  enum Filter: String {
    case assigned
    case created
    case mentioned
    case subscribed
    case all
  }
  
  enum State: String {
    case open
    case closed
    case all
  }
  
  enum Sort: String {
    case created
    case updated
    case comments
  }
  
  static func fetchRepoList(sort: Sort.RawValue) -> Observable<[Repository]> {
    
    guard let token = UserDefaults.loadToken()?.token else { fatalError() }
    
    guard var urlComponents = URLComponents(string: "https://api.github.com/user/repos") else { fatalError() }
    
    let urlParams = [
      "sort": sort
    ]
    
    urlComponents.queryItems = urlParams.map({ (key, value) in
      URLQueryItem(name: key, value: value)
    })
    
    let request: Observable<URLRequest> = Observable.create{ observer in
      let request: URLRequest = {
        var request = URLRequest(url: $0)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        return request
      }(urlComponents.url!)
      
      observer.onNext(request)
      observer.onCompleted()
      return Disposables.create()
    }
    
    return request.flatMap{
      URLSession.shared.rx.response(request: $0)
      }
      //O<(response, data)> -> map -> O<status>
      .map({ (response, data) -> [Repository] in
        if 200 ..< 300 ~= response.statusCode {
          let repos = try! JSONDecoder().decode([Repository].self, from: data)
          print("request token success")
          return repos
        } else if 401 == response.statusCode {
          throw UserNetworkManager.Errors.invalidUserInfo
        } else {
          throw UserNetworkManager.Errors.requestFail
        }
      })
      .catchError({ (error) -> Observable<[Repository]> in
        return Observable.just([])
      })
  }
  
  static func fetchIssueList(token: String, filter: String, state: String, sort: Sort.RawValue, completion: @escaping ([Issue]?) -> Void) {
    
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)

    guard var urlComponents = URLComponents(string: "https://api.github.com/user/issues") else { fatalError() }
    
    let urlParams = [
      "filter": filter,
      "state": state,
      "sort": sort
    ]
    
    urlComponents.queryItems = urlParams.map({ (key, value) in
      URLQueryItem(name: key, value: value)
    })
    
    var request = URLRequest(url: urlComponents.url!)
    request.httpMethod = "GET"
    request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

    let task = session.dataTask(with: request) { (data, response, error) in
      if error == nil {
        guard let response = response as? HTTPURLResponse else { fatalError() }
        let statusCode = response.statusCode
        if statusCode == 200 {
          DispatchQueue.main.async {
            self.didFetchIssueList(data: data, response: response, error: error, completion: completion)
          }
        }
      } else {
        print("fetch issue error")
      }
    }

    task.resume()
    session.finishTasksAndInvalidate()

  }
  
  static func didFetchIssueList(data: Data?, response: URLResponse?, error: Error?, completion: @escaping ([Issue]?) -> Void) {
    if let _ = error {
      completion(nil)
    } else if let data = data, let response = response as? HTTPURLResponse {
      if response.statusCode == 200 {
        do {
          let decoder = JSONDecoder()
          let issueList = try decoder.decode([Issue].self, from: data)
          completion(issueList)
        } catch {
          completion(nil)
        }
      } else {
        completion(nil)
      }
    } else {
      completion(nil)
    }
  }
  
}
