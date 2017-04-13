//
//  Gradiented.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 04. 07..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

protocol Gradiented {
    
    func addGradient(fromColor: CGColor, midColor: CGColor, toColor: CGColor)
}

extension Gradiented where Self: UIView {
    
    func addGradient(fromColor: CGColor, midColor: CGColor, toColor: CGColor) {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
        gradient.colors = [fromColor, midColor, toColor]
        gradient.locations = [0.0, 0.4, 0.6]
        self.layer.addSublayer(gradient)
    }
    
    func addGradient(fromColor: CGColor, midColors: [CGColor], toColor: CGColor) {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
        
        gradient.colors = [fromColor]
        gradient.colors!.append(contentsOf: midColors as [Any])
        gradient.colors!.append(toColor)
        
        gradient.locations = [0.0]
        gradient.locations!.append(contentsOf: buildLocations(midColors.count))
        gradient.locations!.append(1.0)
        
        self.layer.addSublayer(gradient)
    }
    
    private func buildLocations(_ count: Int) -> [NSNumber] {
        var result = [NSNumber]()
        var location: Float = 0.0
        
        for _ in 1..<count {
            location +=  Float(1.0) / Float(count)
            result.append(location as NSNumber)
        }
        
        return result
    }
}
