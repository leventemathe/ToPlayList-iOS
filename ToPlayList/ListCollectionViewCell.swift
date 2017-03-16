//
//  ListCollectionViewCell.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 01. 25..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ListCollectionViewCell: UICollectionViewCell, ReusableView, UIGestureRecognizerDelegate, DropShadowed {
    
    
    @IBOutlet weak var coverImg: UIImageView! {
        didSet {
            coverImg.clipsToBounds = true
        }
    }
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var star: UIImageView!
    
    private var _game: Game!
    
    var game: Game {
        return _game
    }
    
    func update(_ game: Game) {
        _game = game
        
        titleLbl.text = game.name
        if let coverURL = game.coverSmallURL {
            coverImg.kf.setImage(with: coverURL, placeholder: #imageLiteral(resourceName: "img_missing_cover"))
        } else {
            coverImg.image = #imageLiteral(resourceName: "img_missing_cover")
        }
    }
    
    // SWIPING
    
    private var shouldPan = false
    
    // This masked view contains Content, and masks swiping while allowing drop shadows for the cell
    @IBOutlet weak var maskedView: UIView!
    
    @IBOutlet weak var backgroundPlayedViewText: UILabel!
    @IBOutlet weak var backgroundPlayedViewView: UIView!
    
    @IBOutlet weak var backgroundDeleteViewView: UIView!
    
    @IBOutlet weak var backgroundDeleteViewText: UILabel!
    
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var contentLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentRightConstraint: NSLayoutConstraint!
    
    private var contentLeftConstant: CGFloat!
    private var contentRightConstant: CGFloat!
    
    private var backgroundViewPlayedStartingColor: UIColor!
    private var backgroundViewPlayedTargetColor = UIColor.MyCustomColors.orange
    private var backgroundTextPlayedStartingColor: UIColor!
    private var backgroundTextPlayedTargetColor = UIColor.white
    
    private var backgroundViewDeleteStartingColor: UIColor!
    private var backgroundViewDeleteTargetColor = UIColor.MyCustomColors.red
    private var backgroundTextDeleteStartingColor: UIColor!
    private var backgroundTextDeleteTargetColor = UIColor.white
    
    private var backgroundPlayedEdge: CGFloat {
        return backgroundPlayedViewView.bounds.size.width
    }
    
    private var backgroundDeleteEdge: CGFloat {
        return backgroundDeleteViewView.bounds.size.width
    }
    
    private var doTresholdLeft: CGFloat!
    private var doTresholdRight: CGFloat!
    
    private var panRecognizer: UIPanGestureRecognizer!
    private var panStartPoint: CGPoint!
    
    var networkErrorHandlerDelegate: ErrorHandlerDelegate?
    
    override func awakeFromNib() {
        setupDropShadow()
        setupStartingValues()
        setupPanRecognizer()
    }
    
    private func setupDropShadow() {
        addDropShadow()
        maskedView.layer.masksToBounds = true
    }
    
    private func setupStartingValues() {
        contentLeftConstant = contentLeftConstraint.constant
        contentRightConstant = contentRightConstraint.constant
        backgroundViewPlayedStartingColor = backgroundPlayedViewView.backgroundColor!
        backgroundTextPlayedStartingColor = backgroundPlayedViewText.textColor!
        backgroundViewDeleteStartingColor = backgroundDeleteViewView.backgroundColor!
        backgroundTextDeleteStartingColor = backgroundDeleteViewText.textColor!
        doTresholdLeft = backgroundPlayedEdge * 0.75
        doTresholdRight = backgroundDeleteEdge * 0.75
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
            print("cancelled")
        default:
            break
        }
    }
    
    private func panBegan() {
        setShouldPan()
        panStartPoint = panRecognizer.translation(in: content)
    }
    
    private func setShouldPan() {
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
        moveContent(newPosX)
        animateColor(newPosX)
    }
    
    private func panEnded() {
        shouldPan = false
        doNetworking()
        panEndedAnimation()
    }
    
    private func moveContent(_ position: CGFloat) {
        //let position = position > backgroundPlayedEdge ? backgroundPlayedEdge : position
        var position = position
        if position > backgroundPlayedEdge {
            position = backgroundPlayedEdge
        } else if -position > backgroundDeleteEdge {
            position = -backgroundDeleteEdge
        }
        showHideNeededBackground(position)
        contentLeftConstraint.constant = position
        contentRightConstraint.constant = -position
    }
    
    private func showHideNeededBackground(_ position: CGFloat) {
        if position > 0 && backgroundPlayedViewView.isHidden {
            backgroundPlayedViewView.isHidden = false
            backgroundDeleteViewView.isHidden = true
        } else if position < 0 && backgroundDeleteViewView.isHidden {
            backgroundPlayedViewView.isHidden = true
            backgroundDeleteViewView.isHidden = false
        }
    }
    
    private enum ColorState {
        case to
        case from
    }
    
    private var colorStateLeft = ColorState.to
    private var colorStateRight = ColorState.to
    
    private func animateColor(_ newPosX: CGFloat) {
        if newPosX < 0 {
            animateColorRight()
        } else if newPosX > 0 {
            animateColorLeft()
        }
    }
    
    private func animateColorLeft() {
        if contentLeftConstraint.constant >= doTresholdLeft {
            if case .to = colorStateLeft {
                animateColorToTargetLeft()
                colorStateLeft = .from
            }
        } else if contentLeftConstraint.constant <= doTresholdLeft {
            if case .from = colorStateLeft {
                animateColorFromTargetLeft()
                colorStateLeft = .to
            }
        }
    }
    
    private func animateColorRight() {
        if contentRightConstraint.constant >= doTresholdRight {
            if case .to = colorStateRight {
                animateColorToTargetRight()
                colorStateRight = .from
            }
        } else if contentRightConstraint.constant <= doTresholdRight {
            if case .from = colorStateRight {
                animateColorFromTargetRight()
                colorStateRight = .to
            }
        }
    }
    
    private func animateColorToTargetLeft() {
        UIView.animate(withDuration: 0.4, animations: {
            self.backgroundPlayedViewView.backgroundColor = self.backgroundViewPlayedTargetColor
            self.backgroundPlayedViewText.textColor = self.backgroundTextPlayedTargetColor
        })
    }
    
    private func animateColorFromTargetLeft() {
        UIView.animate(withDuration: 0.4, animations: {
            self.backgroundPlayedViewView.backgroundColor = self.backgroundViewPlayedStartingColor
            self.backgroundPlayedViewText.textColor = self.backgroundTextPlayedStartingColor
        })
    }
    
    private func animateColorToTargetRight() {
        UIView.animate(withDuration: 0.4, animations: {
            self.backgroundDeleteViewView.backgroundColor = self.backgroundViewDeleteTargetColor
            self.backgroundDeleteViewText.textColor = self.backgroundTextDeleteTargetColor
        })
    }
    
    private func animateColorFromTargetRight() {
        UIView.animate(withDuration: 0.4, animations: {
            self.backgroundDeleteViewView.backgroundColor = self.backgroundViewDeleteStartingColor
            self.backgroundDeleteViewText.textColor = self.backgroundTextDeleteStartingColor
        })
    }
    
    private func panEndedAnimation() {
        UIView.animate(withDuration: 0.1, animations: {
            self.contentLeftConstraint.constant = self.contentLeftConstant
            self.contentRightConstraint.constant = self.contentRightConstant
            if case .from = self.colorStateLeft {
                self.backgroundPlayedViewView.backgroundColor = self.backgroundViewPlayedStartingColor
                self.backgroundPlayedViewText.textColor = self.backgroundTextPlayedStartingColor
            }
            if case .from = self.colorStateRight {
                self.backgroundDeleteViewView.backgroundColor = self.backgroundViewDeleteStartingColor
                self.backgroundDeleteViewText.textColor = self.backgroundTextDeleteStartingColor
            }
            self.layoutIfNeeded()
        })
    }
    
    private func doNetworking() {
        if contentLeftConstraint.constant >= doTresholdLeft {
            addGameToOtherList()
        } else if contentRightConstraint.constant >= doTresholdRight {
            deleteGameFromToPlayList()
        }
    }
    
    private func addGameToOtherList() {
        ListsList.instance.addGameToPlayedList({ result in
            switch result {
            case .failure(_):
                self.networkErrorHandlerDelegate?.handleError(Alerts.UNKNOWN_ERROR)
            case .succes(_):
                break
            }
        }, thisGame: _game)
    }
    
    private func deleteGameFromToPlayList() {
        ListsList.instance.removeGameFromToPlayList(_game) { result in
            switch result {
            case .failure(_):
                self.networkErrorHandlerDelegate?.handleError(Alerts.UNKNOWN_ERROR)
            case .succes(_):
                break
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !shouldPan
    }
}








