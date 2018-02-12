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
  
  //이슈를 몽땅 가져와서 로컬에서 사용할 형태로 변형
  func getAllData(issueApi: IssueServiceRepresentable) -> Observable<[Int:Repository]> {
    
    return issueApi.fetchAllIssues(filter: .all, state: .all, sort: .created, page: 1)
      .debug("-------getalldata------------")
      .map { issueArr -> [Int:Repository] in
        var dict = [Repository:[Issue]]()
        for issue in issueArr {
          if let _ = dict[issue.repository!] {
            dict[issue.repository!]?.append(issue)
          } else {
            dict[issue.repository!] = [issue]
          }
        }
        
        var resultRepoList = [Int:Repository]()
        for (key, value) in dict {
          var tempRepo = key
          tempRepo.setIssuesDic(issueArr: value)
          resultRepoList[tempRepo.id] = tempRepo
        }
        
        return resultRepoList
      }
  }
}
