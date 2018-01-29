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
  static let shared: LocalDataManager = LocalDataManager()
  
  //local
  private let resultProvider = Variable<[Repository]>([])
  private let bag = DisposeBag()
  
  init() {
    APIDataManager().getAllData()
      .bind(to: resultProvider)
      .disposed(by: bag)
  }
  
  func provider() -> Observable<[Repository]> {
    return resultProvider.asObservable()
  }
  
  func getRepo(index: Int) -> Repository {
    return resultProvider.value[index]
  }
  
  func createIssue(newIssue: Issue, repoIndex: Int) {
    resultProvider.value[repoIndex].issuesDic![newIssue.id] = newIssue
  }
  
  func closeIssue(newIssue: Issue, repoIndex: Int) {
    resultProvider.value[repoIndex].issuesDic?.removeValue(forKey: newIssue.id)
  }
  
  func editIssue(newIssue: Issue, repoIndex: Int) {
    resultProvider.value[repoIndex].issuesDic?.updateValue(newIssue, forKey: newIssue.id)
  }
  
  func fetchComments(repoIndex: Int, issue: Issue, comments: [Comment]) {
    resultProvider.value[repoIndex].issuesDic![issue.id]?.setCommentsDic(comments: comments)
  }
  
  func createComment(repoIndex: Int, issue: Issue, newComment: Comment) {
    resultProvider.value[repoIndex].issuesDic![issue.id]?.commentsDic![newComment.id] = newComment
  }
  
  func editComment(repoIndex: Int, issue: Issue, newComment: Comment) {
    resultProvider.value[repoIndex].issuesDic![issue.id]?.commentsDic?.updateValue(newComment, forKey: newComment.id)
  }
  
  func deleteComment(repoIndex: Int, issue: Issue, existingComment: Comment) {
    resultProvider.value[repoIndex].issuesDic![issue.id]?.commentsDic?.removeValue(forKey: existingComment.id)
  }
}
