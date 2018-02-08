//
//  IssueService.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 28..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Moya

protocol IssueServiceRepresentable {
  var currentPage: BehaviorRelay<Int> { get }
  func fetchAllIssues(filter: IssueService.Filter,
                      state: IssueService.State,
                      sort: IssueService.Sort,
                      page: Int) -> Observable<[Issue]>
  func createIssue(title: String,
                   body: String,
                   label: [IssueService.Label],
                   repo: Repository,
                   users: [User]) -> Observable<Issue>
  func editIssue(title: String,
                 body: String,
                 label: [IssueService.Label],
                 issue: Issue,
                 state: IssueService.State,
                 repo: Repository,
                 assignees: [User]) -> Observable<Issue>
  func fetchComments(issue: Issue) -> Observable<[Comment]>
  func createComment(issue: Issue, commentBody: String) -> Observable<Comment>
  func editComment(issue: Issue,
                   comment: Comment,
                   newCommentText: String) -> Observable<Comment>
  func deleteComment(issue: Issue, comment: Comment) -> Observable<Bool>
  func getUser() -> Observable<Bool>
  func getAssignees(repo: Repository) -> Observable<[User]>
}

class IssueService: IssueServiceRepresentable {
  
  var currentPage: BehaviorRelay<Int> = BehaviorRelay<Int>(value: 1)
  var lastPage = Variable<Int>(-1)
  private var tempIssueArr = [Issue]()
  let provider = MoyaProvider<IssueAPI>()
  
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
    static let arr: [State] = [.open, .closed, .all]
  }
  
  enum Sort: String {
    case created
    case updated
    static let arr: [Sort] = [.created, .updated]
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
    static let arr: [Label] = [.bug, .duplicate, .enhancement, .goodFirstIssue,
                               .helpWanted, .invalid, .model, .question, .wontfix]
  }
  
  func transformStrToState(stateString: String) -> IssueService.State? {
    for state in IssueService.State.arr {
      if stateString == state.rawValue {
        return state
      }
    }
    return nil
  }
  
  func transformIssueLabelToLabel(
    issueLabelArr: [IssueLabel]) -> [IssueService.Label] {
    let strArr: [String] = issueLabelArr.map { $0.name }
    var tempArr = [IssueService.Label]()
    for str in strArr {
      for label in IssueService.Label.arr {
        if str == label.rawValue {
          tempArr.append(label)
        }
      }
    }
    return tempArr
  }
  
  func fetchAllIssues(filter: Filter,
                      state: State,
                      sort: Sort,
                      page: Int) -> Observable<[Issue]> {
    return self.provider.rx.request(.fetchAllIssues(
      filter: filter,
      state: state,
      sort: sort,
      page: page))
      .asObservable()
      .map { [weak self] (result) -> [Issue] in
        let response = result.response!
        let data = result.data
        if let link = response.allHeaderFields["Link"] as? String,
          self?.lastPage.value == -1 {
          self?.lastPage.value = (self?.getLastPageFromLinkHeader(link: link))!
        }
        if 200 ..< 300 ~= response.statusCode {
          let issues = try! JSONDecoder().decode([Issue].self, from: data)
          for issue in issues {
            self?.tempIssueArr.append(issue)
          }
          if (self?.currentPage.value)! < (self?.lastPage.value)! {
            let tempPage = (self?.currentPage.value)! + 1
            self?.currentPage.accept(tempPage)
            return []
          }
          return (self?.tempIssueArr)!
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }.catchError({ (error) -> Observable<[Issue]> in
        return Observable.just([])
      })
    
  }
  
  func createIssue(title: String, body: String,
                   label: [Label], repo: Repository,
                   users: [User]) -> Observable<Issue> {
    return self.provider.rx.request(.createIssue(
      title: title,
      body: body,
      label: label,
      repo: repo,
      users: users))
      .asObservable()
      .map({ (result) -> Issue in
        let response = result.response!
        let data = result.data
        if 200 ..< 300 ~= response.statusCode {
          let newIssue = try! JSONDecoder().decode(Issue.self, from: data)
          return newIssue
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }).catchError({ (error) -> Observable<Issue> in
        print(error.localizedDescription)
        return Observable.just(Issue())
      })
  }
  
  
  
  func editIssue(title: String, body: String,
                 label: [IssueService.Label],
                 issue: Issue, state: IssueService.State,
                 repo: Repository,
                 assignees: [User]) -> Observable<Issue> {
    
    return self.provider.rx.request(.editIssue(
      title: title,
      body: body,
      label: label,
      issue: issue,
      state: state,
      repo: repo,
      assignees: assignees))
      .asObservable()
      .map({ (result) -> Issue in
        let response = result.response!
        let data = result.data
        if 200 ..< 300 ~= response.statusCode {
          let newIssue = try! JSONDecoder().decode(Issue.self, from: data)
          return newIssue
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }).catchError({ (error) -> Observable<Issue> in
        print(error.localizedDescription)
        return Observable.just(Issue())
      })
    
  }
  
  func fetchComments(issue: Issue) -> Observable<[Comment]> {
    
    return self.provider.rx.request(.fetchComments(issue: issue))
      .asObservable()
      .map({ (result) -> [Comment] in
        let response = result.response!
        let data = result.data
        if 200 ..< 300 ~= response.statusCode {
          let comments = try! JSONDecoder().decode([Comment].self, from: data)
          
          return comments
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }).catchError({ (error) -> Observable<[Comment]> in
        return Observable.just([])
      })
  }
  
  func createComment(issue: Issue, commentBody: String) -> Observable<Comment> {
    return self.provider.rx.request(.createComment(issue: issue,
                                                   commentBody: commentBody))
      .asObservable()
      .map({ (result) -> Comment in
        let response = result.response!
        let data = result.data
        if 200 ..< 300 ~= response.statusCode {
          let newComment = try! JSONDecoder().decode(Comment.self, from: data)
          return newComment
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }).catchError({ (error) -> Observable<Comment> in
        return Observable.just(Comment())
      })
  }
  
  
  
  func editComment(issue: Issue, comment: Comment,
                   newCommentText: String) -> Observable<Comment> {
    return self.provider.rx.request(.editComment(issue: issue,
                                                 comment: comment,
                                                 newCommentText: newCommentText))
      .asObservable()
      .map({ (result) -> Comment in
        let response = result.response!
        let data = result.data
        if 200 ..< 300 ~= response.statusCode {
          let newComment = try! JSONDecoder().decode(Comment.self, from: data)
          return newComment
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }).catchError({ (error) -> Observable<Comment> in
        return Observable.just(Comment())
      })
    
  }
  
  func deleteComment(issue: Issue, comment: Comment) -> Observable<Bool> {
    return self.provider.rx.request(.deleteComment(issue: issue,
                                                   comment: comment))
      .asObservable()
      .map({ (result) -> Bool in
        let response = result.response!
        if 200 ..< 300 ~= response.statusCode {
          return true
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }).catchError({ (error) -> Observable<Bool> in
        return Observable.just(false)
      })
  }
  
  func getUser() -> Observable<Bool> {
    return self.provider.rx.request(.getUser())
      .asObservable()
      .map({ (result) -> Bool in
        let response = result.response!
        let data = result.data
        if 200 ..< 300 ~= response.statusCode {
          let me = try! JSONDecoder().decode(User.self, from: data)
          Me.shared.setUser(me: me)
          return true
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      }).catchError({ (error) -> Observable<Bool> in
        return Observable.just(false)
      })
  }
  
  //이것만 Moya를 적용하면 에러남
//  func getAssignees(repo: Repository) -> Observable<[User]> {
//    return self.provider.rx.request(.getAssignees(repo: repo))
//      .asObservable()
//      .map({ (result) -> [User] in
//        let response = result.response!
//        let data = result.data
//        if 200 ..< 300 ~= response.statusCode {
//          let users = try! JSONDecoder().decode([User].self, from: data)
//          return users
//        } else if 401 == response.statusCode {
//          throw AuthService.Errors.invalidUserInfo
//        } else {
//          throw AuthService.Errors.requestFail
//        }
//      }).catchError({ (error) -> Observable<[User]> in
//        return Observable.just([])
//      })
//  }
  
  func getAssignees(repo: Repository) -> Observable<[User]> {
    guard let urlComponents =
      URLComponents(string: "https://api.github.com/repos/\(repo.owner.login)/\(repo.name)/assignees")
      else { fatalError() }

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
      .map({ (response, data) -> [User] in
        if 200 ..< 300 ~= response.statusCode {
          let users = try! JSONDecoder().decode([User].self, from: data)

          return users
        } else if 401 == response.statusCode {
          throw AuthService.Errors.invalidUserInfo
        } else {
          throw AuthService.Errors.requestFail
        }
      })
      .catchError({ (error) -> Observable<[User]> in
        return Observable.just([])
      })
  }
  
  
  
  //helper
  func getLastPageFromLinkHeader(link: String) -> Int {
    let temp = link.components(separatedBy: "=")[7]
    let lastPage = Int((temp.components(separatedBy: "&")[0]))!
    return lastPage
  }
}
