//
//  IssueDataManager.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation

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

  
  static func fetchRepoList(sort: Sort.RawValue, completion: @escaping ([Repository]?) -> Void) {
    
    guard let token = UserDefaults.standard.loadToken()?.token else { return }
    
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    
    guard var urlComponents = URLComponents(string: "https://api.github.com/user/repos") else { fatalError() }
    
    let urlParams = [
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
            self.didFetchRepoList(data: data, response: response, error: error, completion: completion)
          }
        }
      } else {
        print("fetch repoList error")
      }
    }
    
    task.resume()
    session.finishTasksAndInvalidate()
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
  
  static func didFetchRepoList(data: Data?, response: URLResponse?, error: Error?, completion: @escaping ([Repository]?) -> Void) {
    if let _ = error {
      completion(nil)
    } else if let data = data, let response = response as? HTTPURLResponse {
      if response.statusCode == 200 {
        let repoList = try! JSONDecoder().decode([Repository].self, from: data)
        print("fetch repo success")
        completion(repoList)
      } else {
        print("fetch repo fail 1")
        completion(nil)
      }
    } else {
      print("fetch repo fail 2")
      completion(nil)
    }
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
