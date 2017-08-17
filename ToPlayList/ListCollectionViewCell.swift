//
//  ListCollectionViewCell.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 25..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

enum ColorState {
    case to
    case from
}

class ListCollectionViewCell: UICollectionViewCell, ReusableView, DropShadowed {
    
    
    @IBOutlet weak var coverImg: UIImageView! {
        didSet {
            coverImg.clipsToBounds = true
        }
    }
    @IBOutlet weak var titleLbl: UILabel!
    
    var game: Game!
    
    weak var networkErrorHandlerDelegate: ErrorHandlerDelegate?
    
    func update(_ game: Game) {
        self.game = game
        
        titleLbl.text = game.name
        if let coverURL = game.coverBigURL {
            coverImg.image = nil
            coverImg.kf.setImage(with: coverURL, placeholder: #imageLiteral(resourceName: "img_missing_cover"), options: nil, progressBlock: nil, completionHandler: { (image, _, _, _) in
                if image == nil && self.game.coverSmallURL != nil {
                    self.coverImg.kf.setImage(with: self.game.coverSmallURL, placeholder: #imageLiteral(resourceName: "img_missing_cover"))
                }
            })
        } else {
            coverImg.image = #imageLiteral(resourceName: "img_missing_cover")
        }
    }
    
    // This masked view contains Content, and masks swiping while allowing drop shadows for the cell
    @IBOutlet weak var maskedView: UIView!
    
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var contentLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentRightConstraint: NSLayoutConstraint!
    
    weak var onPanDelegate: OnPanDelegate?
    
    override func awakeFromNib() {
        setupDropShadow()
    }
    
    private func setupDropShadow() {
        addDropShadow()
        maskedView.layer.masksToBounds = true
    }
    
    func panChanged(_ currentPoint: CGPoint, fromStartingPoint panStartPoint: CGPoint) {
        let newPosX = currentPoint.x - panStartPoint.x
        onPanDelegate?.moveContent(newPosX)
        onPanDelegate?.animateColor(newPosX)
    }
    
    func panEnded() {
        onPanDelegate?.doNetworking()
        onPanDelegate?.panEndedAnimation()
    }
}









