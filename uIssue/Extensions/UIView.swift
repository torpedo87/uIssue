//
//  UIView.swift
//  uIssue
//
//  Created by junwoo on 2018. 2. 9..
//  Copyright © 2018년 samchon. All rights reserved.
//

import UIKit

extension UIView {
  
  //키보드에 맞춰서 뷰 위아래로 이동
  func keyboardWillChange(_ notification: Notification) {
    let duration =
      notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
    let curve =
      notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
    let startingFrame =
      (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
    let endingFrame =
      (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let deltaY = endingFrame.origin.y - startingFrame.origin.y
    
    UIView.animateKeyframes(withDuration: duration,
                            delay: 0.0,
                            options: UIViewKeyframeAnimationOptions.init(rawValue: curve),
                            animations: { self.frame.origin.y += deltaY },
                            completion: nil)
  }
}
