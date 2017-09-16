//
//  NavigationControllerWithCustomBackGestureDelegate.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 08. 15..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class NavigationControllerWithCustomBackGestureDelegate: UINavigationController, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        interactivePopGestureRecognizer?.delegate = self
        interactivePopGestureRecognizer?.addTarget(self, action: #selector(NavigationControllerWithCustomBackGestureDelegate.backGesturePanning(_:)))
    }
    
    @objc func backGesturePanning(_ gestureRecognizer: UIGestureRecognizer?) {
        if let rec = gestureRecognizer {
            switch rec.state {
            case .began:
                resetNavbar()
            default:
                break
            }
        }
    }
    
    func makeNavbarTransparent() {
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.topItem?.title = ""
    }
    
    func resetNavbar() {
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.shadowImage = nil
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // this ugly hack prevents going back to register/login vc from lists and user not verified vc
        // it's needed, because even though i removed the back button, gestures still worked to go back
        if let visibleVC = visibleViewController {
            if visibleVC is ListVC || visibleVC is UserNotVerifiedVC {
                return false
            }
        }
        return viewControllers.count > 1
    }
    
    // i don't know why this works, and shouldRequireFailureOf doesn't...
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}





