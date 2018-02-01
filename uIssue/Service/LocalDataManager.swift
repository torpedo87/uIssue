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
  private let resultProvider = Variable<[Repository]>([])
  private let bag = DisposeBag()
  
  func bindOutput(issueApi: IssueServiceRepresentable) {
    IssueListFetcher().getAllData(issueApi: issueApi)
      .map({ (repoList) -> [Repository] in
        return repoList.sorted(by: { $0.created_at > $1.created_at })
      })
      .bind(to: resultProvider)
      .disposed(by: bag)
  }
  
  func getProvider() -> Observable<[Repository]> {
    return resultProvider.asObservable()
  }
  
  func getRepo(index: Int) -> Repository {
    return resultProvider.value[index]
  }
  
  func createIssue(newIssue: Issue, repoIndex: Int) {
    if let _ = resultProvider.value[repoIndex].issuesDic {
      resultProvider.value[repoIndex].issuesDic![newIssue.id] = newIssue
    } else {
      resultProvider.value[repoIndex].issuesDic = [Int:Issue]()
      resultProvider.value[repoIndex].issuesDic![newIssue.id] = newIssue
    }
  }
  
  func closeIssue(newIssue: Issue, repoIndex: Int) {
    resultProvider.value[repoIndex].issuesDic?.removeValue(forKey: newIssue.id)
  }
  
  func editIssue(newIssue: Issue, repoIndex: Int) {
    resultProvider.value[repoIndex].issuesDic?.updateValue(newIssue, forKey: newIssue.id)
  }
  
  func fetchComments(repoIndex: Int, issue: Issue, comments: [Comment]) {
    print("------fetchcomment==========")
    if let _ = resultProvider.value[repoIndex].issuesDic {
      resultProvider.value[repoIndex].issuesDic![issue.id]?.setCommentsDic(comments: comments)
    } else {
      resultProvider.value[repoIndex].issuesDic = [Int:Issue]()
      resultProvider.value[repoIndex].issuesDic![issue.id]?.setCommentsDic(comments: comments)
    }
  }
  
  func createComment(repoIndex: Int, issue: Issue, newComment: Comment) {
    if let _ = resultProvider.value[repoIndex].issuesDic {
      if let _ = resultProvider.value[repoIndex].issuesDic![issue.id]?.commentsDic {
        resultProvider.value[repoIndex].issuesDic![issue.id]?.commentsDic![newComment.id] = newComment
      } else {
        resultProvider.value[repoIndex].issuesDic![issue.id]?.commentsDic = [Int:Comment]()
        resultProvider.value[repoIndex].issuesDic![issue.id]?.commentsDic![newComment.id] = newComment
      }
    } else {
      resultProvider.value[repoIndex].issuesDic = [Int:Issue]()
      resultProvider.value[repoIndex].issuesDic![issue.id]?.commentsDic![newComment.id] = newComment
    }
    
  }
  
  func editComment(repoIndex: Int, issue: Issue, newComment: Comment) {
    if newComment.body != "" {
      resultProvider.value[repoIndex].issuesDic![issue.id]?.commentsDic?.updateValue(newComment, forKey: newComment.id)
    }
  }
  
  func deleteComment(repoIndex: Int, issue: Issue, existingComment: Comment) {
    resultProvider.value[repoIndex].issuesDic![issue.id]?.commentsDic?.removeValue(forKey: existingComment.id)
  }
  
  //for test
  func setRepoList(repoList: [Repository]) {
    resultProvider.value = repoList
  }
  
  func removeAll() {
    resultProvider.value = []
  }
  
}
