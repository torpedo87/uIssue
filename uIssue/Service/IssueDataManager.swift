//
//  IssueDataManager.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation

class IssueDataManager: IssueDataService {
  
  static func fetchIssueList(userId: String, userPassword: String, filter: String, state: String, completion: @escaping ([Issue]?) -> Void) {
    
    let config = URLSessionConfiguration.default
    let userInfoString = userId + ":" + userPassword
    guard let userInfoData = userInfoString.data(using: String.Encoding.utf8) else { return }
    let base64EncodedCredential = userInfoData.base64EncodedString()
    let authString = "Basic \(base64EncodedCredential)"
    let session = URLSession(configuration: config)

    guard var urlComponents = URLComponents(string: "https://api.github.com/user/issues") else { fatalError() }
    
    let urlParams = [
      "filter": filter,
      "state": state
    ]
    
    urlComponents.queryItems = urlParams.map({ (key, value) in
      URLQueryItem(name: key, value: value)
    })
    
    var request = URLRequest(url: urlComponents.url!)
    request.httpMethod = "GET"
    request.addValue(authString, forHTTPHeaderField: "Authorization")
    request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

    let task = session.dataTask(with: request) { (data, response, error) in
      print("aaa")
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
