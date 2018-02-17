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
  private let bag = DisposeBag()
  private var tempIssueArr = [Issue]()
  var provider: MoyaProvider<IssueAPI>!
  
  init(provider: MoyaProvider<IssueAPI> = MoyaProvider<IssueAPI>()) {
    self.provider = provider
  }
  
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
    
    return paging()
      .flatMap { [unowned self] in
        self.provider.rx.request(.fetchAllIssues(filter: .all,
                                                 state: .all,
                                                 sort: .created,
                                                 page: $0))
      }
      .reduce([Issue](), accumulator: { issues, response in
        let decoded = try! JSONDecoder().decode([Issue].self, from: response.data)
        return issues + decoded
      })
    
  }
  
  private func paging() -> Observable<Int> {
    return Observable.create { observer in
      self.provider.request(.fetchAllIssues(filter: .all,
                                            state: .all,
                                            sort: .created,
                                            page: 1))
      { result in
        
        var lastPage = Int()
        if let link = result.value?.response?.allHeaderFields["Link"] as? String {
          lastPage = (self.getLastPageFromLinkHeader(link: link))
        }
        
        switch result {
        case .success(let response):
          if 200 ..< 300 ~= response.statusCode {
            for page in 1...lastPage {
              observer.onNext(page)
            }
            observer.onCompleted()
          } else if 401 == response.statusCode {
            observer.onError(AuthService.Errors.invalidUserInfo)
          } else {
            observer.onError(AuthService.Errors.requestFail)
          }
        case .failure(let error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    }
  }
  
  func createIssue(title: String, body: String,
                   label: [Label], repo: Repository,
                   users: [User]) -> Observable<Issue> {
    return Observable.create({ (observer) -> Disposable in
      self.provider.request(.createIssue(title: title, body: body, label: label,
                                         repo: repo, users: users)) { (result) in
        switch result {
        case let .success(moyaResponse):
          let data = moyaResponse.data
          let statusCode = moyaResponse.statusCode
          if 200 ..< 300 ~= statusCode {
            let newIssue = try! JSONDecoder().decode(Issue.self, from: data)
            observer.onNext(newIssue)
          } else if 401 == statusCode {
            observer.onError(AuthService.Errors.invalidUserInfo)
          } else {
            observer.onError(AuthService.Errors.requestFail)
          }
        case let .failure(error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    })
    
  }
  
  func editIssue(title: String, body: String,
                 label: [IssueService.Label],
                 issue: Issue, state: IssueService.State,
                 repo: Repository,
                 assignees: [User]) -> Observable<Issue> {
    return Observable.create({ (observer) -> Disposable in
      self.provider.request(.editIssue(title: title, body: body, label: label,
                                       issue: issue, state: state, repo: repo,
                                       assignees: assignees)) { (result) in
        switch result {
        case let .success(moyaResponse):
          let data = moyaResponse.data
          let statusCode = moyaResponse.statusCode
          if 200 ..< 300 ~= statusCode {
            let newIssue = try! JSONDecoder().decode(Issue.self, from: data)
            observer.onNext(newIssue)
          } else if 401 == statusCode {
            observer.onError(AuthService.Errors.invalidUserInfo)
          } else {
            observer.onError(AuthService.Errors.requestFail)
          }
        case let .failure(error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    })
    
  }
  
  func fetchComments(issue: Issue) -> Observable<[Comment]> {
    return Observable.create({ (observer) -> Disposable in
      self.provider.request(.fetchComments(issue: issue)) { (result) in
        switch result {
        case let .success(moyaResponse):
          let data = moyaResponse.data
          let statusCode = moyaResponse.statusCode
          if 200 ..< 300 ~= statusCode {
            let comments = try! JSONDecoder().decode([Comment].self, from: data)
            observer.onNext(comments)
          } else if 401 == statusCode {
            observer.onError(AuthService.Errors.invalidUserInfo)
          } else {
            observer.onError(AuthService.Errors.requestFail)
          }
        case let .failure(error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    })
    
  }
  
  func createComment(issue: Issue, commentBody: String) -> Observable<Comment> {
    return Observable.create({ (observer) -> Disposable in
      self.provider.request(.createComment(issue: issue,
                                           commentBody: commentBody)) { (result) in
        switch result {
        case let .success(moyaResponse):
          let data = moyaResponse.data
          let statusCode = moyaResponse.statusCode
          if 200 ..< 300 ~= statusCode {
            let newComment = try! JSONDecoder().decode(Comment.self, from: data)
            observer.onNext(newComment)
          } else if 401 == statusCode {
            observer.onError(AuthService.Errors.invalidUserInfo)
          } else {
            observer.onError(AuthService.Errors.requestFail)
          }
        case let .failure(error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    })
    
  }
  
  func editComment(issue: Issue, comment: Comment,
                   newCommentText: String) -> Observable<Comment> {
    return Observable.create({ (observer) -> Disposable in
      self.provider.request(.editComment(issue: issue,
                                         comment: comment,
                                         newCommentText: newCommentText)) { (result) in
        switch result {
        case let .success(moyaResponse):
          let data = moyaResponse.data
          let statusCode = moyaResponse.statusCode
          if 200 ..< 300 ~= statusCode {
            let newComment = try! JSONDecoder().decode(Comment.self, from: data)
            observer.onNext(newComment)
          } else if 401 == statusCode {
            observer.onError(AuthService.Errors.invalidUserInfo)
          } else {
            observer.onError(AuthService.Errors.requestFail)
          }
        case let .failure(error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    })
    
  }
  
  func deleteComment(issue: Issue, comment: Comment) -> Observable<Bool> {
    return Observable.create({ (observer) -> Disposable in
      self.provider.request(.deleteComment(issue: issue,
                                           comment: comment)) { (result) in
        switch result {
        case let .success(moyaResponse):
          let statusCode = moyaResponse.statusCode
          if 200 ..< 300 ~= statusCode {
            observer.onNext(true)
          } else if 401 == statusCode {
            observer.onError(AuthService.Errors.invalidUserInfo)
          } else {
            observer.onError(AuthService.Errors.requestFail)
          }
        case let .failure(error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    })
  }
  
  func getUser() -> Observable<Bool> {
    return Observable.create({ (observer) -> Disposable in
      self.provider.request(.getUser(), completion: { (result) in
        switch result {
        case let .success(moyaResponse):
          let data = moyaResponse.data
          let statusCode = moyaResponse.statusCode
          if 200 ..< 300 ~= statusCode {
            let me = try! JSONDecoder().decode(User.self, from: data)
            Me.shared.setUser(me: me)
            observer.onNext(true)
          } else if 401 == statusCode {
            observer.onError(AuthService.Errors.invalidUserInfo)
          } else {
            observer.onError(AuthService.Errors.requestFail)
          }
        case let .failure(error):
          observer.onError(error)
        }
      })
      return Disposables.create()
    })
  }
  
  func getAssignees(repo: Repository) -> Observable<[User]> {
    return Observable.create({ (observer) -> Disposable in
      self.provider.request(.getAssignees(repo: repo)) { (result) in
        switch result {
        case let .success(moyaResponse):
          let data = moyaResponse.data
          let statusCode = moyaResponse.statusCode
          if 200 ..< 300 ~= statusCode {
            let users = try! JSONDecoder().decode([User].self, from: data)
            observer.onNext(users)
          } else if 401 == statusCode {
            observer.onError(AuthService.Errors.invalidUserInfo)
          } else {
            observer.onError(AuthService.Errors.requestFail)
          }
        case let .failure(error):
          observer.onError(error)
        }
      }
      return Disposables.create()
    })
    
  }
  
  //helper
  func getLastPageFromLinkHeader(link: String) -> Int {
    let temp = link.components(separatedBy: "=")[7]
    let lastPage = Int((temp.components(separatedBy: "&")[0]))!
    return lastPage
  }
}
