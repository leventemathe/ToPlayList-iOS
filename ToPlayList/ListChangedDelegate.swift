//
//  ListChangedDelegate.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 02. 20..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation

protocol ListChangedDelegate {
    
    func listChanged(_ starState: StarState, forGame game: Game)
}
