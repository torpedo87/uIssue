//
//  IssueService.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation
import RxSwift

class IssueService {
  
  static var currentPage = Variable<Int>(1)
  static var lastPage = -1
  
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
  
  enum Label: String {
    case bug
    case duplicate
    case enhancement
    case goodFirstIssue = "good first issue"
    case helpWanted = "help wanted"
    case invalid
    case model
    case question
    case wontfix
  }
  
  static func fetchAllIssues(filter: Filter, state: State, sort: Sort, page: Int) -> Observable<[Issue]> {
    
    guard let token = UserDefaults.loadToken()?.token else { fatalError() }
    
    guard var urlComponents = URLComponents(string: "https://api.github.com/issues") else { fatalError() }
    
    let urlParams = [
      "sort": sort.rawValue,
      "state": state.rawValue,
      "filter": filter.rawValue,
      "page": "\(page)"
    ]
    
    urlComponents.queryItems = urlParams.map({ (key,value) in
      URLQueryItem(name: key, value: value)
    })
    
    let request: Observable<URLRequest> = Observable.create{ observer in
      let request: URLRequest = {
        var request = URLRequest(url: $0)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
      }(urlComponents.url!)
      
      observer.onNext(request)
      observer.onCompleted()
      return Disposables.create()
    }
    
    return request.flatMap{
      URLSession.shared.rx.response(request: $0)
      }
      .map({ (response, data) -> [Issue] in
        if let link = response.allHeaderFields["Link"] as? String, lastPage == -1 {
          lastPage = getLastPageFromLinkHeader(link: link)
        }
        print("====last=====\(lastPage), ========\(currentPage.value)")
        if 200 ..< 300 ~= response.statusCode {
          let issues = try! JSONDecoder().decode([Issue].self, from: data)
          if currentPage.value < lastPage {
            currentPage.value += 1
          }
          return issues
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      })
      .catchError({ (error) -> Observable<[Issue]> in
        return Observable.just([])
      })
  }
  
  static func createIssue(title: String, comment: String, label: [Label], repo: Repository) -> Observable<Issue> {
    guard let token = UserDefaults.loadToken()?.token else { fatalError() }
    guard let url = URL(string: "https://api.github.com/repos/\(repo.owner.login)/\(repo.name)/issues") else { fatalError() }
    
    let request: Observable<URLRequest> = Observable.create{ observer in
      let request: URLRequest = {
        var request = URLRequest(url: $0)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let bodyObject: [String: Any] = [
          "body": comment,
          "labels": label.map{ $0.rawValue },
          "title": title,
          "assignee": repo.owner.login
        ]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        return request
      }(url)
      
      observer.onNext(request)
      observer.onCompleted()
      return Disposables.create()
    }
    
    return request.flatMap{
      URLSession.shared.rx.response(request: $0)
      }
      
      .map({ (response, data) -> Issue in
        if 200 ..< 300 ~= response.statusCode {
          let newIssue = try! JSONDecoder().decode(Issue.self, from: data)
          return newIssue
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      })
      .catchError({ (error) -> Observable<Issue> in
        return Observable.empty()
      })
    
  }
  
  static func editIssue(title: String, comment: String, label: [Label], issue: Issue, state: State) -> Observable<Issue> {
    guard let token = UserDefaults.loadToken()?.token else { fatalError() }
    let repoName = getRepoNameFromIssue(issue: issue)
    guard let url = URL(string: "https://api.github.com/repos/\(issue.user.login)/\(repoName)/issues/\(issue.number)") else { fatalError() }
    
    let request: Observable<URLRequest> = Observable.create{ observer in
      let request: URLRequest = {
        var request = URLRequest(url: $0)
        request.httpMethod = "PATCH"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let bodyObject: [String: Any] = [
          "body": comment,
          "labels": label.map{ $0.rawValue },
          "title": title,
          "state": state.rawValue,
        ]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyObject, options: [])
        
        return request
      }(url)
      
      observer.onNext(request)
      observer.onCompleted()
      return Disposables.create()
    }
    
    return request.flatMap{
      URLSession.shared.rx.response(request: $0)
      }
      .map({ (response, data) -> Issue in
        if 200 ..< 300 ~= response.statusCode {
          let newIssue = try! JSONDecoder().decode(Issue.self, from: data)
          return newIssue
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      })
      .catchError({ (error) -> Observable<Issue> in
        return Observable.empty()
      })
    
  }
  
  static func getRepoNameFromIssue(issue: Issue) -> String {
    let arr = issue.repository_url.components(separatedBy: "/")
    return arr[5]
  }
  
  static func getLastPageFromLinkHeader(link: String) -> Int {
    let temp = link.components(separatedBy: "=")[7]
    let lastPage = Int((temp.components(separatedBy: "&")[0]))!
    return lastPage
  }
}
