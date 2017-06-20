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

class ListCollectionViewCell: UICollectionViewCell, ReusableView, UIGestureRecognizerDelegate, DropShadowed {
    
    
    @IBOutlet weak var coverImg: UIImageView! {
        didSet {
            coverImg.clipsToBounds = true
        }
    }
    @IBOutlet weak var titleLbl: UILabel!
    
    var game: Game!
    
    var networkErrorHandlerDelegate: ErrorHandlerDelegate?
    
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
    
    var shouldPan = false
    var scrolling = false
    
    private var panRecognizer: UIPanGestureRecognizer!
    private var panStartPoint: CGPoint!
    
    var onPanDelegate: OnPanDelegate?
    
    override func awakeFromNib() {
        setupDropShadow()
        setupPanRecognizer()
    }
    
    private func setupDropShadow() {
        addDropShadow()
        maskedView.layer.masksToBounds = true
    }
    
    private func setupPanRecognizer() {
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        panRecognizer.delegate = self
        content.addGestureRecognizer(panRecognizer)
    }
    
    func pan() {
        switch panRecognizer.state {
        case .began:
            panBegan()
        case .changed:
            panChanged()
        case .ended:
            panEnded()
        case .cancelled:
            print("pan cancelled")
        default:
            break
        }
    }
    
    private func panBegan() {
        setShouldPan()
        panStartPoint = panRecognizer.translation(in: content)
    }
    
    private func setShouldPan() {
        if scrolling {
            shouldPan = false
            return
        }
        
        let velocity = panRecognizer.velocity(in: self)
        if abs(velocity.y) >= abs(velocity.x) {
            shouldPan = false
        } else {
            shouldPan = true
        }
    }
    
    private func panChanged() {
        if !shouldPan {
            return
        }
        
        let currentPoint = panRecognizer.translation(in: content)
        let newPosX = currentPoint.x - panStartPoint.x
        onPanDelegate?.moveContent(newPosX)
        onPanDelegate?.animateColor(newPosX)
    }
    
    private func panEnded() {
        shouldPan = false
        onPanDelegate?.doNetworking()
        onPanDelegate?.panEndedAnimation()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !shouldPan
    }
}








