//
//  IssueListFetcher.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 25..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class IssueListFetcher {
  
  let apiType: IssueServiceRepresentable.Type
  
  init(apiType: IssueServiceRepresentable.Type = IssueService.self) {
    self.apiType = apiType
  }
  
  func getAllData() -> Observable<[Repository]> {
    
    return apiType.currentPage.asObservable()
      .flatMap { [weak self] (page) -> Observable<[Issue]> in
        (self?.apiType.fetchAllIssues(filter: .all, state: .open, sort: .created, page: page))!
      }
      .map { issueArr -> [Repository] in
        
        var dict = [Repository:[Issue]]()
        for issue in issueArr {
          if let _ = dict[issue.repository!] {
            dict[issue.repository!]?.append(issue)
          } else {
            dict[issue.repository!] = [issue]
          }
        }
        
        var resultRepoList = [Repository]()
        for (key, value) in dict {
          var tempRepo = key
          tempRepo.setIssuesDic(issueArr: value)
          resultRepoList.append(tempRepo)
        }
        
        return resultRepoList
    }
  }
}
