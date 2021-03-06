//
//  DetailsImages.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 04. 04..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class DetailsBigScreenshot: UIView, Gradiented {
    
    var gradient: CAGradientLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if gradient != nil {
            //gradient!.frame = self.frame
            return
        }
        
        let fromColor = UIColor.clear.cgColor
        let midColors = [
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2).cgColor,
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4).cgColor,
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6).cgColor
        ]
        let toColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8).cgColor
        
        gradient = addGradient(fromColor: fromColor, midColors: midColors, toColor: toColor)
    }
}

class DetailsCover: UIView, DropShadowed {
    
    override func awakeFromNib() {
        addDropShadow(1.0, withOffset: CGSize.zero)
        setupSwiping()
    }
    
    var game: Game!
    
    var shouldPan = false
    
    weak var errorHandlerDelegate: ErrorHandlerDelegate?
    
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var playedView: UIView!
    @IBOutlet weak var playedText: UILabel!
    @IBOutlet weak var toPlayView: UIView!
    @IBOutlet weak var toPlayText: UILabel!
    
    @IBOutlet weak var contentLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentTrailingConstraint: NSLayoutConstraint!
    
    private var contentLeadingStartingConstant: CGFloat!
    private var contentTrailingStartingConstant: CGFloat!
    
    private var toPlayViewBaseStartingColor = UIColor.lightGray
    private var toPlayTextBaseStartingColor = UIColor.white
    private var playedViewBaseStartingColor = UIColor.white
    private var playedTextBaseStartingColor = UIColor.lightGray
    
    private var toPlayViewStartingColor: UIColor!
    private var playedViewStartingColor: UIColor!
    private var toPlayTextStartingColor: UIColor!
    private var playedTextStartingColor: UIColor!
    
    private var toPlayViewTargetColor = UIColor.white
    private var playedViewTargetColor = UIColor.MyCustomColors.orange
    private var toPlayTextTargetColor = UIColor.MyCustomColors.orange
    private var playedTextTargetColor = UIColor.white
    
    private var leftBackgroundEdge: CGFloat {
        return playedText.frame.size.width
    }
    
    private var rightBackgroundEdge: CGFloat {
        return toPlayText.frame.size.width
    }
    
    private var doTresholdLeft: CGFloat!
    private var doTresholdRight: CGFloat!
    
    private var colorStateLeft = ColorState.to
    private var colorStateRight = ColorState.to
    
    private var panRecognizer: UIPanGestureRecognizer!
    private var panStartPoint: CGPoint!
    
    func setupSwiping() {
        setupConstraints()
        setupStartingValues()
        setupGestureRecognizer()
    }
    
    private func setupConstraints() {
        contentLeadingStartingConstant = contentLeadingConstraint.constant
        contentTrailingStartingConstant = contentTrailingConstraint.constant
    }
    
    private func setupStartingValues() {
        resetBackgrounds()
        
        doTresholdLeft = leftBackgroundEdge * 0.6
        doTresholdRight = rightBackgroundEdge * 0.6
    }
    
    func setupToPlayBackground() {
        toPlayViewStartingColor = toPlayViewTargetColor
        toPlayTextStartingColor = toPlayTextTargetColor
        toPlayView.backgroundColor = toPlayViewStartingColor
        toPlayText.textColor = toPlayTextStartingColor
        
        playedViewStartingColor = playedViewBaseStartingColor
        playedTextStartingColor = playedTextBaseStartingColor
        playedView.backgroundColor = playedViewStartingColor
        playedText.textColor = playedTextStartingColor
    }
    
    func setupPlayedBackground() {
        playedViewStartingColor = playedViewTargetColor
        playedTextStartingColor = playedTextTargetColor
        playedView.backgroundColor = playedViewStartingColor
        playedText.textColor = playedTextStartingColor
        
        toPlayViewStartingColor = toPlayViewBaseStartingColor
        toPlayTextStartingColor = toPlayTextBaseStartingColor
        toPlayView.backgroundColor = toPlayViewStartingColor
        toPlayText.textColor = toPlayTextStartingColor
    }
    
    func resetBackgrounds() {
        toPlayViewStartingColor = toPlayViewBaseStartingColor
        toPlayTextStartingColor = toPlayTextBaseStartingColor
        playedTextStartingColor = playedTextBaseStartingColor
        playedViewStartingColor = playedViewBaseStartingColor
        
        toPlayView.backgroundColor = toPlayViewStartingColor
        toPlayText.textColor = toPlayTextStartingColor
        playedView.backgroundColor = playedViewStartingColor
        playedText.textColor = playedTextStartingColor
    }
    
    private func setupGestureRecognizer() {
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        self.addGestureRecognizer(panRecognizer)
    }
    
    @objc func pan() {
        switch panRecognizer.state {
        case .began:
            panBegan()
        case .changed:
            panChanged()
        case .ended:
            panEnded()
        case .cancelled:
            panEnded()
        default:
            break
        }
    }
    
    private func panBegan() {
        panStartPoint = panRecognizer.translation(in: coverImg)
    }
    
    private func panChanged() {
        if !shouldPan {
            return
        }
        let currentPoint = panRecognizer.translation(in: coverImg)
        let newPosX = currentPoint.x - panStartPoint.x
        moveContent(newPosX)
        animateColor(newPosX)
    }
    
    private func panEnded() {
        addGameToList()
        panEndedAnimation()
    }
    
    private func addGameToList() {
        if contentLeadingConstraint.constant >= doTresholdLeft {
            addGameToPlayedList()
        } else if contentTrailingConstraint.constant >= doTresholdRight {
            addGameToToPlayList()
        }
    }
    
    private func addGameToToPlayList() {
        ListsList.instance.addGameToToPlayList({ result in
            switch result {
            case .success:
                break
            case .failure(_):
                self.errorHandlerDelegate?.handleError(Alerts.UNKNOWN_LISTS_ERROR)
            }
        }, thisGame: game!)
    }
    
    private func addGameToPlayedList() {
        ListsList.instance.addGameToPlayedList({ result in
            switch result {
            case .success:
                break
            case .failure(_):
                self.errorHandlerDelegate?.handleError(Alerts.UNKNOWN_LISTS_ERROR)
            }
        }, thisGame: game!)
    }
    
    private func removeGameFromList() {
        ListsList.instance.removeGameFromToPlayAndPlayedList({result in
            switch result {
            case .success:
                break
            case .failure(_):
                self.errorHandlerDelegate?.handleError(Alerts.UNKNOWN_LISTS_ERROR)
            }
        }, thisGame: game!)
    }
    
    private func panEndedAnimation() {
        UIView.animate(withDuration: 0.1, animations: {
            self.resetContent()
            self.layoutIfNeeded()
        })
    }
    
    private func moveContent(_ newPosX: CGFloat) {
        var newPosX = newPosX
        if newPosX > leftBackgroundEdge {
            newPosX = leftBackgroundEdge
        }
        if -newPosX > rightBackgroundEdge  {
            newPosX = -rightBackgroundEdge
        }
        contentLeadingConstraint.constant = newPosX
        contentTrailingConstraint.constant = -newPosX
    }
    
    private func resetContent() {
        self.contentLeadingConstraint.constant = self.contentLeadingStartingConstant
        self.contentTrailingConstraint.constant = self.contentTrailingStartingConstant
    }
    
    private func animateColor(_ newPosX: CGFloat) {
        if newPosX < 0 {
            animateColorRight()
        } else if newPosX > 0 {
            animateColorLeft()
        }
    }
    
    private func animateColorLeft() {
        if contentLeadingConstraint.constant >= doTresholdLeft {
            if case .to = colorStateLeft {
                animateColorLeftToTarget()
                colorStateLeft = .from
            }
        } else if contentLeadingConstraint.constant <= doTresholdLeft {
            if case .from = colorStateLeft {
                animateColorLeftFromTarget()
                colorStateLeft = .to
            }
        }
    }
    
    private func  animateColorRight() {
        if contentTrailingConstraint.constant >= doTresholdRight {
            if case .to = colorStateRight {
                animateColorRightToTarget()
                colorStateRight = .from
            }
        } else if contentTrailingConstraint.constant <= doTresholdRight {
            if case .from = colorStateRight {
                animateColorRightFromTarget()
                colorStateRight = .to
            }
        }
    }
    
    private func animateColorLeftToTarget() {
        UIView.animate(withDuration: 0.4, animations: {
            self.playedView.backgroundColor = self.playedViewTargetColor
            self.playedText.textColor = self.playedTextTargetColor
        })
    }
    
    private func animateColorLeftFromTarget() {
        UIView.animate(withDuration: 0.4, animations: {
            self.playedView.backgroundColor = self.playedViewStartingColor
            self.playedText.textColor = self.playedTextStartingColor
        })
    }
    
    private func animateColorRightToTarget() {
        UIView.animate(withDuration: 0.4, animations: {
            self.toPlayView.backgroundColor = self.toPlayViewTargetColor
            self.toPlayText.textColor = self.toPlayTextTargetColor
        })
    }
    
    private func animateColorRightFromTarget() {
        UIView.animate(withDuration: 0.4, animations: {
            self.toPlayView.backgroundColor = self.toPlayViewStartingColor
            self.toPlayText.textColor = self.toPlayTextStartingColor
        })
    }

}

class StarBanner: UIImageView, DropShadowed {
    
    override func awakeFromNib() {
        addDropShadow(0.5, withOffset:  CGSize.zero)
    }
}

class ContainerView: UIView, DropShadowed {
    
    override func awakeFromNib() {
        addDropShadow(0.5, withOffset: CGSize.zero)
    }
}
