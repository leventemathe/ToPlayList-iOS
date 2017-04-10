//
//  ViewPanner.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 04. 10..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ViewPanner: UIView, UIGestureRecognizerDelegate {
    
    // set from outside - wether swiping should be allowed or not
    private var shouldSwipe = false
    
    // set from inside - wether panning or scrolling should happen
    private var shouldPan = false
    
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var contentLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentRightConstraint: NSLayoutConstraint!
    
    private var contentLeftConstraintStart: CGFloat!
    private var contentRightConstraintStart: CGFloat!
    
    private var rightBackgroundBaseStartingColor = UIColor.lightGray
    private var rightTextBaseStartingColor = UIColor.white
    private var leftBackgroundBaseStartingColor = UIColor.white
    private var leftTextBaseStartingColor = UIColor.lightGray
    
    private var rightBackgroundStartingColor: UIColor!
    private var rightTextStartingColor: UIColor!
    private var leftBackgroundStartingColor: UIColor!
    private var leftTextStartingColor: UIColor!
    
    private var rightBackgroundTargetColor = UIColor.white
    private var rightTextTargetColor = UIColor.MyCustomColors.orange
    private var leftBackgroundTargetColor = UIColor.MyCustomColors.orange
    private var leftTextTargetColor = UIColor.white
    
    private var leftBackgroundEdge: CGFloat {
        return leftLabel.frame.size.width
    }
    
    private var rightBackgroundEdge: CGFloat {
        return rightLabel.frame.size.width
    }
    
    private var doTresholdLeft: CGFloat!
    private var doTresholdRight: CGFloat!
    
    private var colorStateLeft = ColorState.to
    private var colorStateRight = ColorState.to
    
    private var panRecognizer: UIPanGestureRecognizer!
    private var panStartPoint: CGPoint!
    
    var networkErrorHandlerDelegate: ErrorHandlerDelegate?
    
    override func awakeFromNib() {
        setupConstraints()
        setupStartingValues()
        setupGestureRecognizer()
    }
    
    private func setupConstraints() {
        contentLeftConstraintStart = contentLeftConstraint.constant
        contentRightConstraintStart = contentRightConstraint.constant
    }
    
    private func setupStartingValues() {
        resetBackgrounds()
        
        doTresholdLeft = leftBackgroundEdge * 0.75
        doTresholdRight = rightBackgroundEdge * 0.75
    }
    
    private func setupToPlayBackground() {
        rightBackgroundStartingColor = rightBackgroundTargetColor
        rightTextStartingColor = rightTextTargetColor
        rightLabel.backgroundColor = rightBackgroundStartingColor
        rightLabel.textColor = rightTextStartingColor
        
        leftBackgroundStartingColor = leftBackgroundBaseStartingColor
        leftTextStartingColor = leftTextBaseStartingColor
        leftLabel.backgroundColor = leftBackgroundStartingColor
        leftLabel.textColor = leftTextStartingColor
    }
    
    private func setupPlayedBackground() {
        leftBackgroundStartingColor = leftBackgroundTargetColor
        leftTextStartingColor = leftTextTargetColor
        leftLabel.backgroundColor = leftBackgroundStartingColor
        leftLabel.textColor = leftTextStartingColor
        
        rightBackgroundStartingColor = rightBackgroundBaseStartingColor
        rightTextStartingColor = rightTextBaseStartingColor
        rightLabel.backgroundColor = rightBackgroundStartingColor
        rightLabel.textColor = rightTextStartingColor
    }
    
    private func resetBackgrounds() {
        rightBackgroundStartingColor = rightBackgroundBaseStartingColor
        rightTextStartingColor = rightTextBaseStartingColor
        leftTextStartingColor = leftTextBaseStartingColor
        leftBackgroundStartingColor = leftBackgroundBaseStartingColor
        
        rightLabel.backgroundColor = rightBackgroundStartingColor
        rightLabel.textColor = rightTextStartingColor
        leftLabel.backgroundColor = leftBackgroundStartingColor
        leftLabel.textColor = leftTextStartingColor
    }
    
    private func setupGestureRecognizer() {
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        panRecognizer.delegate = self
        content.addGestureRecognizer(panRecognizer)
    }
    
    func pan(withLeftAction leftAction: @escaping ()->(),
             withRightAction rightAction: @escaping ()->()) {
        switch panRecognizer.state {
        case .began:
            panBegan()
        case .changed:
            panChanged()
        case .ended:
            panEnded(withLeftAction: leftAction, withRightAction: rightAction)
        case .cancelled:
            print("cancelled")
        default:
            break
        }
    }
    
    private func panBegan() {
        let velocity = panRecognizer.velocity(in: self)
        if abs(velocity.y) >= abs(velocity.x) {
            shouldPan = false
        } else {
            shouldPan = true
        }
        panStartPoint = panRecognizer.translation(in: content)
    }
    
    private func panChanged() {
        if !shouldPan {
            return
        }
        if !shouldSwipe {
            return
        }
        
        let currentPoint = panRecognizer.translation(in: content)
        let newPosX = currentPoint.x - panStartPoint.x
        moveContent(newPosX)
        animateColor(newPosX)
    }
    
    private func panEnded(withLeftAction leftAction: @escaping ()->(),
                          withRightAction rightAction: @escaping ()->()) {
        shouldPan = false
        
        if contentLeftConstraint.constant >= doTresholdLeft {
            leftAction()
        } else if contentRightConstraint.constant >= doTresholdRight {
            rightAction()
        }
        
        panEndedAnimation()
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
        contentLeftConstraint.constant = newPosX
        contentRightConstraint.constant = -newPosX
    }
    
    private func resetContent() {
        self.contentLeftConstraint.constant = self.contentLeftConstraintStart
        self.contentRightConstraint.constant = self.contentRightConstraintStart
    }
    
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
                animateColorLeftToTarget()
                colorStateLeft = .from
            }
        } else if contentLeftConstraint.constant <= doTresholdLeft {
            if case .from = colorStateLeft {
                animateColorLeftFromTarget()
                colorStateLeft = .to
            }
        }
    }
    
    private func  animateColorRight() {
        if contentRightConstraint.constant >= doTresholdRight {
            if case .to = colorStateRight {
                animateColorRightToTarget()
                colorStateRight = .from
            }
        } else if contentRightConstraint.constant <= doTresholdRight {
            if case .from = colorStateRight {
                animateColorRightFromTarget()
                colorStateRight = .to
            }
        }
    }
    
    private func animateColorLeftToTarget() {
        UIView.animate(withDuration: 0.4, animations: {
            self.leftLabel.backgroundColor = self.leftBackgroundTargetColor
            self.leftLabel.textColor = self.leftTextTargetColor
        })
    }
    
    private func animateColorLeftFromTarget() {
        UIView.animate(withDuration: 0.4, animations: {
            self.leftLabel.backgroundColor = self.leftBackgroundStartingColor
            self.leftLabel.textColor = self.leftTextStartingColor
        })
    }
    
    private func animateColorRightToTarget() {
        UIView.animate(withDuration: 0.4, animations: {
            self.rightLabel.backgroundColor = self.rightBackgroundTargetColor
            self.rightLabel.textColor = self.rightTextTargetColor
        })
    }
    
    private func animateColorRightFromTarget() {
        UIView.animate(withDuration: 0.4, animations: {
            self.rightLabel.backgroundColor = self.rightBackgroundStartingColor
            self.rightLabel.textColor = self.rightTextStartingColor
        })
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !shouldPan || !shouldSwipe
    }
}
