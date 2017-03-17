//
//  OnPanDelegate.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 03. 17..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

protocol OnPanDelegate {
    
    func moveContent(_ position: CGFloat)
    func animateColor(_ position: CGFloat)
    func doNetworking()
    func panEndedAnimation()
}
