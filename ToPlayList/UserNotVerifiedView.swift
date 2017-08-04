//
//  UserNotVerifiedView.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 08. 04..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

protocol UserNotVerifiedDelegate: class {
    
    func userNotVerifiedResendEmailClicked(_ onComplete: @escaping ()->())
    func userNotVerifiedImVerifiedClicked(_ onComplete: @escaping ()->())
}

class UserNotVerifiedView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var resendEmailButton: LoginSceneButtonLogin!
    @IBOutlet weak var imVerifiedButton: LoginSceneButtonLogin!
    
    weak var delegate: UserNotVerifiedDelegate?
    
    @IBAction func resendEmailClicked(_ sender: LoginSceneButtonLogin) {
        resendEmailButton.startLoadingAnimation()
        delegate?.userNotVerifiedResendEmailClicked({
            self.resendEmailButton.stopLoadingAnimation()
        })
    }
    
    @IBAction func imVerifiedClicked(_ sender: LoginSceneButtonLogin) {
        imVerifiedButton.startLoadingAnimation()
        delegate?.userNotVerifiedImVerifiedClicked({
            self.imVerifiedButton.stopLoadingAnimation()
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    func xibSetup() {
        contentView = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        contentView!.frame = bounds
        
        // Make the view stretch with containing view
        contentView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]

        addSubview(contentView!)
        setupTiltingBackground()
    }
    
    private func loadViewFromNib() -> UIView! {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    private func setupTiltingBackground() {
        let amount = 50
        
        let horizontalMotion = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalMotion.minimumRelativeValue = -amount
        horizontalMotion.maximumRelativeValue = amount
        
        let verticalMotion = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalMotion.minimumRelativeValue = -amount
        verticalMotion.maximumRelativeValue = amount
        
        backgroundView.addMotionEffect(horizontalMotion)
        backgroundView.addMotionEffect(verticalMotion)
    }
}
