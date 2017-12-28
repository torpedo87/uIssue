//
//  UserNetworkService.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 27..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation

protocol UserNetworkService {
  
  func login(userId: String, userPassword: String, completion: @escaping (_ success: Bool, _ token: String?) -> Void)
  
}
