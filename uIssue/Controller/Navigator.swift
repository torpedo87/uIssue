//
//  Navigator.swift
//  uIssue
//
//  Created by junwoo on 2018. 1. 22..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit

class Navigator {
  
  static let shared: Navigator = Navigator()
  
  enum Destination {
    case login
    case repoList
    case issueList(Int)
    case setting
    case createIssue(Int)
    case issueDetail(Int, Int)
  }
  
  func show(destination: Destination, sender: UIViewController) {
    switch destination {
    case .login:
      let vm = LoginViewViewModel()
      show(target: LoginViewController.createWith(viewModel: vm), sender: sender)
    case .repoList:
      let vm = RepoListViewViewModel()
      let repoListVC = RepoListViewController.createWith(viewModel: vm)
      show(target: UINavigationController(rootViewController: repoListVC), sender: sender)
    case .issueList(let repoId):
      let vm = IssueListViewViewModel(repoId: repoId)
      show(target: IssueListViewController.createWith(viewModel: vm), sender: sender)
    case .setting:
      let vm = SettingViewViewModel()
      show(target: SettingViewController.createWith(viewModel: vm), sender: sender)
    case .createIssue(let repoId):
      let vm = CreateIssueViewViewModel(repoId: repoId)
      show(target: CreateIssueViewController.createWith(viewModel: vm), sender: sender)
    case .issueDetail(let repoId, let issueId):
      let vm = IssueDetailViewViewModel(repoId: repoId, issueId: issueId)
      show(target: IssueDetailViewController.createWith(viewModel: vm), sender: sender)
    }
  }
  
  func unwindTo(target: UIViewController) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    appDelegate.window?.rootViewController = target
  }
  
  private func show(target: UIViewController, sender: UIViewController) {
    if let _ = target as? CreateIssueViewController {
      sender.present(target, animated: true, completion: nil)
      return
    }
    if let nav = sender as? UINavigationController {
      nav.pushViewController(target, animated: false)
      return
    }
    
    if let nav = sender.navigationController {
      nav.pushViewController(target, animated: true)
    } else {
      sender.present(target, animated: true, completion: nil)
    }
  }
}
