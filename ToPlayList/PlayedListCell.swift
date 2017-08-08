//
//  PlayedListCell.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 03. 17..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class PlayedListCell: ListCollectionViewCell, OnPanDelegate {
    
    @IBOutlet weak var backgroundToPlayViewText: UILabel!
    @IBOutlet weak var backgroundToPlayViewView: UIView!
    
    @IBOutlet weak var backgroundDeleteViewView: UIView!
    @IBOutlet weak var backgroundDeleteViewText: UILabel!
    
    private var contentLeftConstant: CGFloat!
    private var contentRightConstant: CGFloat!
    
    private var backgroundViewToPlayStartingColor: UIColor!
    private var backgroundViewToPlayTargetColor = UIColor.white
    private var backgroundTextToPlayStartingColor: UIColor!
    private var backgroundTextToPlayTargetColor = UIColor.MyCustomColors.orange
    
    private var backgroundViewDeleteStartingColor: UIColor!
    private var backgroundViewDeleteTargetColor = UIColor.MyCustomColors.red
    private var backgroundTextDeleteStartingColor: UIColor!
    private var backgroundTextDeleteTargetColor = UIColor.white
    
    private var backgroundToPlayEdge: CGFloat {
        return backgroundToPlayViewView.bounds.size.width
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
        backgroundViewToPlayStartingColor = backgroundToPlayViewView.backgroundColor!
        backgroundTextToPlayStartingColor = backgroundToPlayViewText.textColor!
        backgroundViewDeleteStartingColor = backgroundDeleteViewView.backgroundColor!
        backgroundTextDeleteStartingColor = backgroundDeleteViewText.textColor!
        doTresholdRight = backgroundToPlayEdge * 0.75
        doTresholdLeft = backgroundDeleteEdge * 0.75
    }
    
    func moveContent(_ position: CGFloat) {
        var position = position
        if position > backgroundDeleteEdge {
            position = backgroundDeleteEdge
        } else if -position > backgroundToPlayEdge {
            position = -backgroundToPlayEdge
        }
        showHideNeededBackground(position)
        contentLeftConstraint.constant = position
        contentRightConstraint.constant = -position
    }
    
    private func showHideNeededBackground(_ position: CGFloat) {
        if position > 0 && backgroundDeleteViewView.isHidden {
            backgroundDeleteViewView.isHidden = false
            backgroundToPlayViewView.isHidden = true
        } else if position < 0 && backgroundToPlayViewView.isHidden {
            backgroundDeleteViewView.isHidden = true
            backgroundToPlayViewView.isHidden = false
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
            self.backgroundDeleteViewView.backgroundColor = self.backgroundViewDeleteTargetColor
            self.backgroundDeleteViewText.textColor = self.backgroundTextDeleteTargetColor
        })
    }
    
    private func animateColorFromTargetLeft() {
        UIView.animate(withDuration: 0.4, animations: {
            self.backgroundDeleteViewView.backgroundColor = self.backgroundViewDeleteStartingColor
            self.backgroundDeleteViewText.textColor = self.backgroundTextDeleteStartingColor
        })
    }
    
    private func animateColorToTargetRight() {
        UIView.animate(withDuration: 0.4, animations: {
            self.backgroundToPlayViewView.backgroundColor = self.backgroundViewToPlayTargetColor
            self.backgroundToPlayViewText.textColor = self.backgroundTextToPlayTargetColor
        })
    }
    
    private func animateColorFromTargetRight() {
        UIView.animate(withDuration: 0.4, animations: {
            self.backgroundToPlayViewView.backgroundColor = self.backgroundViewToPlayStartingColor
            self.backgroundToPlayViewText.textColor = self.backgroundTextToPlayStartingColor
        })
    }
    
    func panEndedAnimation() {
        UIView.animate(withDuration: 0.1, animations: {
            self.contentLeftConstraint.constant = self.contentLeftConstant
            self.contentRightConstraint.constant = self.contentRightConstant
            if case .from = self.colorStateLeft {
                self.backgroundDeleteViewView.backgroundColor = self.backgroundViewDeleteStartingColor
                self.backgroundDeleteViewText.textColor = self.backgroundTextDeleteStartingColor
            }
            if case .from = self.colorStateRight {
                self.backgroundToPlayViewView.backgroundColor = self.backgroundViewToPlayStartingColor
                self.backgroundToPlayViewText.textColor = self.backgroundTextToPlayStartingColor
            }
            self.layoutIfNeeded()
        })
    }
    
    func doNetworking() {
        if contentLeftConstraint.constant >= doTresholdLeft {
            deleteGameFromPlayedList()
        } else if contentRightConstraint.constant >= doTresholdRight {
            addGameToOtherList()
        }
    }
    
    private func addGameToOtherList() {
        ListsList.instance.addGameToToPlayList({ result in
            switch result {
            case .failure(_):
                self.networkErrorHandlerDelegate?.handleError(Alerts.UNKNOWN_ERROR)
            case .success(_):
                break
            }
        }, thisGame: game)
    }
    
    private func deleteGameFromPlayedList() {
        ListsList.instance.removeGameFromPlayedList(game) { result in
            switch result {
            case .failure(_):
                self.networkErrorHandlerDelegate?.handleError(Alerts.UNKNOWN_ERROR)
            case .success(_):
                break
            }
        }
    }
}
