//
//  UserNetworkService.swift
//  uIssue
//
//  Created by junwoo on 2017. 12. 27..
//  Copyright © 2017년 samchon. All rights reserved.
//

import Foundation
import RxSwift

protocol UserNetworkService {
  
  static func login(userId: String, userPassword: String) -> Single<(Int, String)>
  
  static func logout(userId: String, userPassword: String, tokenId: Int, completion: @escaping (_ statusCode: Int?) -> Void)
}
