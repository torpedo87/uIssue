//
//  APIDataManager.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 25..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class APIDataManager {
  
  func getAllData() -> Observable<[Repository]> {
    
    return IssueService.currentPage.asObservable()
      .flatMap { (page) in
        IssueService.fetchAllIssues(filter: .all, state: .open, sort: .created, page: page)
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
          var temp = key
          temp.setIssuesDic(issueArr: value)
          resultRepoList.append(temp)
        }
        
        return resultRepoList
    }
  }
}
