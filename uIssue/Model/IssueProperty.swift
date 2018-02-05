//
//  IssueProperty.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 6..
//  Copyright © 2018년 samchon. All rights reserved.
//

import Foundation
import RxDataSources

enum MultipleSectionModel {
  case LabelSection(title: String, items: [SectionItem])
  case AssigneeSection(title: String, items: [SectionItem])
}

enum SectionItem {
  case LabelSectionItem(label: IssueService.Label)
  case AssigneeSectionItem(user: User)
}

extension MultipleSectionModel: SectionModelType {
  typealias Item = SectionItem
  
  init(original: MultipleSectionModel, items: [Item]) {
    switch original {
    case let .LabelSection(title: title, _):
      self = .LabelSection(title: title, items: items)
    case let .AssigneeSection(title: title, _):
      self = .AssigneeSection(title: title, items: items)
    }
  }
  
  var items: [SectionItem] {
    switch  self {
    case .LabelSection(title: _, let items):
      return items.map {$0}
    case .AssigneeSection(title: _, let items):
      return items.map {$0}
    }
  }
}

extension MultipleSectionModel {
    var title: String {
      switch self {
      case .LabelSection(title: let title, items: _):
        return title
      case .AssigneeSection(title: let title, items: _):
        return title
      }
    }
}
