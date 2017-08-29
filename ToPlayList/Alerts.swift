//
//  Alerts.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 22..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class Alerts: UIViewController {

    static let NETWORK_ERROR = "No internet connection."
    static let SERVER_ERROR = "There was an error with the server, please check back later."
    static let UNKNOWN_ERROR = "An unknown error occured."
    static let UNKNOWN_LISTS_ERROR = "An unknown error occured while fetching list data."
    
    static func alertWithOKButton(withMessage message: String, forVC vc: UIViewController) {
        let alert = UIAlertController(title: "Error 😟", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okBtn)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func alertSuccessWithOKButton(withMessage message: String, forVC vc: UIViewController) {
        let alert = UIAlertController(title: "Success!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okBtn = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(okBtn)
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func alertWithYesAndNoButtons(withTitle title: String, withMessage message: String, forVC vc: UIViewController, withOnYes onYes: @escaping ()->()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okBtn = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
            onYes()
        })
        alert.addAction(okBtn)
        let cancelBtn = UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(cancelBtn)
        vc.present(alert, animated: true, completion: nil)
    }
}
