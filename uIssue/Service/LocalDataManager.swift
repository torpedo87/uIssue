//
//  LocalDataManager.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 24..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class LocalDataManager {
  
  static let shared = LocalDataManager()
  
  //local
  private let resultProvider = BehaviorRelay<[Int:Repository]>(value: [Int:Repository]())
  private let bag = DisposeBag()
  
  func bindOutput(issueApi: IssueServiceRepresentable) {
    IssueListFetcher().getAllData(issueApi: issueApi)
      .bind(to: resultProvider)
      .disposed(by: bag)
  }
  
  func getProvider() -> Observable<[Int:Repository]> {
    return resultProvider.asObservable()
  }
  
  func getRepo(repoId: Int) -> Repository {
    return resultProvider.value[repoId]!
  }
  
  func createIssue(repoId: Int, createdIssue: Issue) {
    let repo = resultProvider.value[repoId]
    var issueWithRepo = createdIssue
    issueWithRepo.repository = repo
    var tempDict = resultProvider.value
    if let _ = resultProvider.value[repoId]?.issuesDic {
      tempDict[repoId]?.issuesDic![createdIssue.id] = issueWithRepo
      resultProvider.accept(tempDict)
    } else {
      tempDict[repoId]?.issuesDic = [Int:Issue]()
      tempDict[repoId]?.issuesDic![createdIssue.id] = issueWithRepo
      resultProvider.accept(tempDict)
    }
  }
  
  func closeIssue(repoId: Int, existingIssue: Issue) {
    var tempDict = resultProvider.value
    tempDict[repoId]?.issuesDic?.removeValue(forKey: existingIssue.id)
    resultProvider.accept(tempDict)
  }
  
  func editIssue(repoId: Int, newIssue: Issue) {
    let repo = resultProvider.value[repoId]
    let commetsDict = resultProvider.value[repoId]?.issuesDic?[newIssue.id]?.commentsDic
    var issue = newIssue
    issue.repository = repo
    issue.commentsDic = commetsDict
    issue.isCommentsFetched = true
    var tempDict = resultProvider.value
    tempDict[repoId]?.issuesDic?.updateValue(issue, forKey: newIssue.id)
    resultProvider.accept(tempDict)
  }
  
  func fetchComments(repoId: Int, issue: Issue, comments: [Comment]) {
    var tempDict = resultProvider.value
    if let _ = resultProvider.value[repoId]?.issuesDic {
      tempDict[repoId]?.issuesDic![issue.id]?
        .setCommentsDic(comments: comments)
      resultProvider.accept(tempDict)
    } else {
      tempDict[repoId]?.issuesDic = [Int:Issue]()
      tempDict[repoId]?.issuesDic![issue.id]?
        .setCommentsDic(comments: comments)
      resultProvider.accept(tempDict)
    }
  }
  
  func createComment(repoId: Int, issue: Issue, newComment: Comment) {
    var tempDict = resultProvider.value
    if let _ = resultProvider.value[repoId]?.issuesDic {
      if let _ = resultProvider.value[repoId]?.issuesDic![issue.id]?.commentsDic {
        tempDict[repoId]?.issuesDic![issue.id]?.commentsDic![newComment.id]
          = newComment
        resultProvider.accept(tempDict)
      } else {
        tempDict[repoId]?.issuesDic![issue.id]?.commentsDic
          = [Int:Comment]()
        tempDict[repoId]?.issuesDic![issue.id]?.commentsDic![newComment.id]
          = newComment
        resultProvider.accept(tempDict)
      }
    } else {
      tempDict[repoId]?.issuesDic = [Int:Issue]()
      tempDict[repoId]?.issuesDic![issue.id]?.commentsDic![newComment.id]
        = newComment
      resultProvider.accept(tempDict)
    }
    
  }
  
  func editComment(repoId: Int, issue: Issue, newComment: Comment) {
    var tempDict = resultProvider.value
    if newComment.body != "" {
      tempDict[repoId]?.issuesDic![issue.id]?.commentsDic?
        .updateValue(newComment, forKey: newComment.id)
      resultProvider.accept(tempDict)
    }
  }
  
  func deleteComment(repoId: Int, issue: Issue, existingComment: Comment) {
    var tempDict = resultProvider.value
    tempDict[repoId]?.issuesDic![issue.id]?.commentsDic?
      .removeValue(forKey: existingComment.id)
    resultProvider.accept(tempDict)
  }
  
  func setAssigneesDic(repoId: Int, assignees: [User]) {
    var tempDict = resultProvider.value
    if let _ = resultProvider.value[repoId]?.assigneesDic {
      tempDict[repoId]?.setassigneesDic(userArr: assignees)
      resultProvider.accept(tempDict)
    } else {
      tempDict[repoId]?.assigneesDic = [Int:User]()
      tempDict[repoId]?.setassigneesDic(userArr: assignees)
      resultProvider.accept(tempDict)
    }
    
  }
  
  //for test
  func setRepoDict(repoDict: [Int:Repository]) {
    resultProvider.accept(repoDict)
  }
  
  func removeAll() {
    resultProvider.accept([Int:Repository]())
  }
  
}
