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
    
    func backGesturePanning(_ gestureRecognizer: UIGestureRecognizer?) {
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
        return viewControllers.count > 1
    }
    
    // This is necessary because without it, subviews of your top controller can
    // cancel out your gesture recognizer on the edge.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
