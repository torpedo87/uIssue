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
  static var lastPage = Variable<Int>(-1)
  
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
        if let link = response.allHeaderFields["Link"] as? String, lastPage.value == -1 {
          lastPage.value = getLastPageFromLinkHeader(link: link)
        }
        print("====last=====\(lastPage.value), ========\(currentPage.value)")
        if 200 ..< 300 ~= response.statusCode {
          let issues = try! JSONDecoder().decode([Issue].self, from: data)
          if currentPage.value < lastPage.value {
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
        return Observable.just(Issue())
      })
    
  }
  
  static func editIssue(title: String, comment: String, label: [Label], issue: Issue, state: State, repo: Repository) -> Observable<Issue> {
    guard let token = UserDefaults.loadToken()?.token else { fatalError() }
    let repoName = repo.name
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
        return Observable.just(Issue())
      })
  }
  
  static func fetchComments(issue: Issue) -> Observable<[Comment]> {
    
    guard let urlComponents = URLComponents(string: issue.comments_url) else { fatalError() }
    
    let request: Observable<URLRequest> = Observable.create{ observer in
      let request: URLRequest = {
        var request = URLRequest(url: $0)
        request.httpMethod = "GET"
        
        return request
      }(urlComponents.url!)
      
      observer.onNext(request)
      observer.onCompleted()
      return Disposables.create()
    }
    
    return request.flatMap{
      URLSession.shared.rx.response(request: $0)
      }
      .map({ (response, data) -> [Comment] in
        if 200 ..< 300 ~= response.statusCode {
          let comments = try! JSONDecoder().decode([Comment].self, from: data)
          
          return comments
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      })
      .catchError({ (error) -> Observable<[Comment]> in
        return Observable.just([])
      })
  }
  
  func createComment(issue: Issue, commentBody: String) -> Observable<Comment> {
    guard let repo = issue.repository else { fatalError() }
    guard let token = UserDefaults.loadToken()?.token else { fatalError() }
    guard let url = URL(string: "https://api.github.com/repos/\(repo.owner.login)/\(repo.name)/issues/\(issue.number)/comments") else { fatalError() }
    
    let request: Observable<URLRequest> = Observable.create{ observer in
      let request: URLRequest = {
        var request = URLRequest(url: $0)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let bodyObject: [String: String] = [
          "body": commentBody
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
      
      .map({ (response, data) -> Comment in
        if 200 ..< 300 ~= response.statusCode {
          let newComment = try! JSONDecoder().decode(Comment.self, from: data)
          return newComment
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      })
      .catchError({ (error) -> Observable<Comment> in
        return Observable.just(Comment())
      })
  }
  
  
  
  func editComment(issue: Issue, comment: Comment) -> Observable<Comment> {
    guard let repo = issue.repository else { fatalError() }
    guard let token = UserDefaults.loadToken()?.token else { fatalError() }
    guard let url = URL(string: "https://api.github.com/repos/\(repo.owner.login)/\(repo.name)/issues/comments/\(comment.id)") else { fatalError() }
    
    let request: Observable<URLRequest> = Observable.create{ observer in
      let request: URLRequest = {
        var request = URLRequest(url: $0)
        request.httpMethod = "PATCH"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let bodyObject: [String: String] = [
          "body": comment.body
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
      
      .map({ (response, data) -> Comment in
        if 200 ..< 300 ~= response.statusCode {
          let newComment = try! JSONDecoder().decode(Comment.self, from: data)
          return newComment
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      })
      .catchError({ (error) -> Observable<Comment> in
        return Observable.just(Comment())
      })
  }
  
  func deleteComment(issue: Issue, comment: Comment) -> Observable<Bool> {
    guard let repo = issue.repository else { fatalError() }
    guard let token = UserDefaults.loadToken()?.token else { fatalError() }
    guard let url = URL(string: "https://api.github.com/repos/\(repo.owner.login)/\(repo.name)/issues/comments/\(comment.id)") else { fatalError() }
    
    let request: Observable<URLRequest> = Observable.create{ observer in
      let request: URLRequest = {
        var request = URLRequest(url: $0)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
      }(url)
      
      observer.onNext(request)
      observer.onCompleted()
      return Disposables.create()
    }
    
    return request.flatMap{
      URLSession.shared.rx.response(request: $0)
      }
      
      .map({ (response, data) -> Bool in
        if 200 ..< 300 ~= response.statusCode {
          return true
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      })
      .catchError({ (error) -> Observable<Bool> in
        return Observable.just(false)
      })
  }
  
  //helper
  static func getLastPageFromLinkHeader(link: String) -> Int {
    let temp = link.components(separatedBy: "=")[7]
    let lastPage = Int((temp.components(separatedBy: "&")[0]))!
    return lastPage
  }
}
