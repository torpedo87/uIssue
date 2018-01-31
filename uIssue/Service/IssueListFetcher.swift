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
  
  func getAllData(issueApi: IssueServiceRepresentable) -> Observable<[Repository]> {
    
    return issueApi.currentPage.asObservable()
      .flatMap { (page) -> Observable<[Issue]> in
        issueApi.fetchAllIssues(filter: .all, state: .open, sort: .created, page: page)
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
