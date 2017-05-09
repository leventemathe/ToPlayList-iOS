//
//  DidSetDelegate.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 05. 09..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import Foundation
import UIKit

protocol CollectionViewSizeDidSetDelegate {

    func didSet(numberOfItems: Int, sizeOfItems: CGSize)
}
