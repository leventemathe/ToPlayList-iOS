//
//  ToPlayListCell.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 03. 17..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ToPlayListCell: ListCollectionViewCell, OnPanDelegate {
    
    @IBOutlet weak var backgroundPlayedViewText: UILabel!
    @IBOutlet weak var backgroundPlayedViewView: UIView!
    
    @IBOutlet weak var backgroundDeleteViewView: UIView!
    
    @IBOutlet weak var backgroundDeleteViewText: UILabel!
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStartingValues()
        onPanDelegate = self
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
    
    func moveContent(_ position: CGFloat) {
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
    
    private var colorStateLeft = ColorState.to
    private var colorStateRight = ColorState.to
    
    func animateColor(_ newPosX: CGFloat) {
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
    
    func panEndedAnimation() {
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
    
    func doNetworking() {
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
        }, thisGame: game)
    }
    
    private func deleteGameFromToPlayList() {
        ListsList.instance.removeGameFromToPlayList(game) { result in
            switch result {
            case .failure(_):
                self.networkErrorHandlerDelegate?.handleError(Alerts.UNKNOWN_ERROR)
            case .succes(_):
                break
            }
        }
    }
}
