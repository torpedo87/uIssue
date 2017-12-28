//
//  UserNetworkManager.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 27..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation

class UserNetworkManager: UserNetworkService {
  
  static var shared = UserNetworkManager()
  
  func login(userId: String, userPassword: String, completion: @escaping (Bool, String?) -> Void) {
    
    let config = URLSessionConfiguration.default
    let userInfoString = userId + ":" + userPassword
    guard let userInfoData = userInfoString.data(using: String.Encoding.utf8) else { return }
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
    
    
    let task = session.dataTask(with: request) { (data, response, error) in
      if error == nil {
        if let data = data,
          let json = try? JSONSerialization.jsonObject(with: data, options: []),
          let dict = json as? [String:Any] {
          
          guard let token = dict["token"] as? String else { fatalError() }
          completion(true, token)
        }
      } else {
        completion(false, nil)
        print("error", error.debugDescription)
      }
    }
    
    task.resume()
  }
}
