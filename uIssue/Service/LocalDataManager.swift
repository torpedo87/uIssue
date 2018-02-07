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
  private let resultProvider = Variable<[Int:Repository]>([Int:Repository]())
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
    if let _ = resultProvider.value[repoId]?.issuesDic {
      resultProvider.value[repoId]?.issuesDic![createdIssue.id] = issueWithRepo
    } else {
      resultProvider.value[repoId]?.issuesDic = [Int:Issue]()
      resultProvider.value[repoId]?.issuesDic![createdIssue.id] = issueWithRepo
    }
  }
  
  func closeIssue(repoId: Int, existingIssue: Issue) {
    resultProvider.value[repoId]?.issuesDic?.removeValue(forKey: existingIssue.id)
  }
  
  func editIssue(repoId: Int, newIssue: Issue) {
    let repo = resultProvider.value[repoId]
    let commetsDict = resultProvider.value[repoId]?.issuesDic?[newIssue.id]?.commentsDic
    var issue = newIssue
    issue.repository = repo
    issue.commentsDic = commetsDict
    issue.isCommentsFetched = true
    resultProvider.value[repoId]?.issuesDic?.updateValue(issue, forKey: newIssue.id)
  }
  
  func fetchComments(repoId: Int, issue: Issue, comments: [Comment]) {

    if let _ = resultProvider.value[repoId]?.issuesDic {
      resultProvider.value[repoId]?.issuesDic![issue.id]?.setCommentsDic(comments: comments)
    } else {
      resultProvider.value[repoId]?.issuesDic = [Int:Issue]()
      resultProvider.value[repoId]?.issuesDic![issue.id]?.setCommentsDic(comments: comments)
    }
  }
  
  func createComment(repoId: Int, issue: Issue, newComment: Comment) {
    if let _ = resultProvider.value[repoId]?.issuesDic {
      if let _ = resultProvider.value[repoId]?.issuesDic![issue.id]?.commentsDic {
        resultProvider.value[repoId]?.issuesDic![issue.id]?.commentsDic![newComment.id] = newComment
      } else {
        resultProvider.value[repoId]?.issuesDic![issue.id]?.commentsDic = [Int:Comment]()
        resultProvider.value[repoId]?.issuesDic![issue.id]?.commentsDic![newComment.id] = newComment
      }
    } else {
      resultProvider.value[repoId]?.issuesDic = [Int:Issue]()
      resultProvider.value[repoId]?.issuesDic![issue.id]?.commentsDic![newComment.id] = newComment
    }
    
  }
  
  func editComment(repoId: Int, issue: Issue, newComment: Comment) {
    if newComment.body != "" {
      resultProvider.value[repoId]?.issuesDic![issue.id]?.commentsDic?.updateValue(newComment, forKey: newComment.id)
    }
  }
  
  func deleteComment(repoId: Int, issue: Issue, existingComment: Comment) {
    resultProvider.value[repoId]?.issuesDic![issue.id]?.commentsDic?.removeValue(forKey: existingComment.id)
  }
  
  func setAssigneesDic(repoId: Int, assignees: [User]) {
    if let _ = resultProvider.value[repoId]?.assigneesDic {
      resultProvider.value[repoId]?.setassigneesDic(userArr: assignees)
    } else {
      resultProvider.value[repoId]?.assigneesDic = [Int:User]()
      resultProvider.value[repoId]?.setassigneesDic(userArr: assignees)
    }
    
  }
  
  //for test
  func setRepoDict(repoDict: [Int:Repository]) {
    resultProvider.value = repoDict
  }
  
  func removeAll() {
    resultProvider.value = [Int:Repository]()
  }
  
}
