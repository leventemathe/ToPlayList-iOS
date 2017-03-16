//
//  NewestReleasesCell.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2016. 12. 21..
//  Copyright © 2016. Máthé Levente. All rights reserved.
//

import UIKit

typealias RGBAComponents = (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)

enum StarState {
    case none
    case toPlay
    case played
}

class NewestReleasesCell: UITableViewCell, ReusableView {

    // UPDATING
    
    @IBOutlet weak var coverView: ListImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var developerLabel: UILabel!
    @IBOutlet weak var star: UIImageView!
    
    private weak var _game: Game?
    
    var game: Game? {
        return _game
    }
    
    func update(_ game: Game) {
        self._game = game
        
        titleLabel.text = game.name
        if let thumbnailURL = game.thumbnailURL {
            coverView.kf.setImage(with: thumbnailURL, placeholder: #imageLiteral(resourceName: "img_missing"))
        } else {
            coverView.image = #imageLiteral(resourceName: "img_missing")
        }
        if let genre = game.genre {
            genreLabel.text = genre.name
        }
        if let developer = game.developer {
            developerLabel.text = developer.name
        }
    }
    
    func updateStar(_ starState: StarState) {
        switch starState {
        case .toPlay:
            setStarToToPlay()
            setupToPlayBackground()
        case .played:
            setStarToPlayed()
            setupPlayedBackground()
        case .none:
            setStarToNone()
            resetBackgrounds()
        }
    }
    
    func updateSwipeable(_ shouldSwipe: Bool) {
        self.shouldSwipe = shouldSwipe
    }
    
    // SWIPING
    
    // set from outside - wether swiping should be allowed or not
    private var shouldSwipe = false
    
    // set from inside - wether panning or scrolling should happen
    private var shouldPan = false
    
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var toPlayView: UIView!
    @IBOutlet weak var toPlayText: UILabel!
    @IBOutlet weak var playedView: UIView!
    @IBOutlet weak var playedText: UILabel!
    
    @IBOutlet weak var contentLeading: NSLayoutConstraint!
    @IBOutlet weak var contentTrailing: NSLayoutConstraint!
    
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
        return playedView.frame.size.width
    }
    
    private var rightBackgroundEdge: CGFloat {
        return toPlayView.frame.size.width
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
        contentLeadingStartingConstant = contentLeading.constant
        contentTrailingStartingConstant = contentTrailing.constant
    }
    
    private func setupStartingValues() {
        resetBackgrounds()
        
        doTresholdLeft = leftBackgroundEdge * 0.75
        doTresholdRight = rightBackgroundEdge * 0.75
    }
    
    private func setupToPlayBackground() {
        toPlayViewStartingColor = toPlayViewTargetColor
        toPlayTextStartingColor = toPlayTextTargetColor
        toPlayView.backgroundColor = toPlayViewStartingColor
        toPlayText.textColor = toPlayTextStartingColor
        
        playedViewStartingColor = playedViewBaseStartingColor
        playedTextStartingColor = playedTextBaseStartingColor
        playedView.backgroundColor = playedViewStartingColor
        playedText.textColor = playedTextStartingColor
    }
    
    private func setupPlayedBackground() {
        playedViewStartingColor = playedViewTargetColor
        playedTextStartingColor = playedTextTargetColor
        playedView.backgroundColor = playedViewStartingColor
        playedText.textColor = playedTextStartingColor
        
        toPlayViewStartingColor = toPlayViewBaseStartingColor
        toPlayTextStartingColor = toPlayTextBaseStartingColor
        toPlayView.backgroundColor = toPlayViewStartingColor
        toPlayText.textColor = toPlayTextStartingColor
    }
    
    private func resetBackgrounds() {
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
        panRecognizer.delegate = self
        content.addGestureRecognizer(panRecognizer)
        
        star.isUserInteractionEnabled = true
        let starTap = UITapGestureRecognizer(target: self, action: #selector(starTapped))
        star.addGestureRecognizer(starTap)
    }
    
    func starTapped() {
        removeGameFromList()
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
    
    private func panEnded() {
        shouldPan = false
        addGameToList()
        panEndedAnimation()
    }
    
    private func addGameToList() {
        if contentLeading.constant >= doTresholdLeft {
            addGameToPlayedList()
        } else if contentTrailing.constant >= doTresholdRight {
            addGameToToPlayList()
        }
    }
    
    private func addGameToToPlayList() {
        ListsList.instance.addGameToToPlayList({ result in
            switch result {
            case .succes:
                break
            case .failure(_):
                self.networkErrorHandlerDelegate?.handleError(Alerts.UNKNOWN_ERROR)
            }
        }, thisGame: game!)
    }
    
    private func addGameToPlayedList() {
        ListsList.instance.addGameToPlayedList({ result in
            switch result {
            case .succes:
                break
            case .failure(_):
                self.networkErrorHandlerDelegate?.handleError(Alerts.UNKNOWN_ERROR)
            }
        }, thisGame: game!)
    }
    
    private func removeGameFromList() {
        ListsList.instance.removeGameFromToPlayAndPlayedList({result in
            switch result {
            case .succes:
                break
            case .failure(_):
                self.networkErrorHandlerDelegate?.handleError(Alerts.UNKNOWN_ERROR)
            }
        }, thisGame: game!)
    }
    
    private func setStarToToPlay() {
        if !isStarToPlay() {
            star.image = #imageLiteral(resourceName: "star_to_play_list")
        }
        star.isHidden = false
    }
    
    private func setStarToPlayed() {
        if !isStarPlayed() {
            star.image = #imageLiteral(resourceName: "star_played_list")
        }
        star.isHidden = false
    }
    
    private func setStarToNone() {
        star.image = nil
        star.isHidden = true
    }
    
    private func isStarToPlay() -> Bool {
        return star.image == #imageLiteral(resourceName: "star_to_play_list")
    }
    
    private func isStarPlayed() -> Bool {
        return star.image == #imageLiteral(resourceName: "star_played_list")
    }
    
    private func isStarNone() -> Bool {
        return star.image == nil
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
        contentLeading.constant = newPosX
        contentTrailing.constant = -newPosX
    }
    
    private func resetContent() {
        self.contentLeading.constant = self.contentLeadingStartingConstant
        self.contentTrailing.constant = self.contentTrailingStartingConstant
    }
    
    private func animateColor(_ newPosX: CGFloat) {
        if newPosX < 0 {
            animateColorRight()
        } else if newPosX > 0 {
            animateColorLeft()
        }
    }
    
    private func animateColorLeft() {
        if contentLeading.constant >= doTresholdLeft {
            if case .to = colorStateLeft {
                animateColorLeftToTarget()
                colorStateLeft = .from
            }
        } else if contentLeading.constant <= doTresholdLeft {
            if case .from = colorStateLeft {
                animateColorLeftFromTarget()
                colorStateLeft = .to
            }
        }
    }
    
    private func  animateColorRight() {
        if contentTrailing.constant >= doTresholdRight {
            if case .to = colorStateRight {
                animateColorRightToTarget()
                colorStateRight = .from
            }
        } else if contentTrailing.constant <= doTresholdRight {
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
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !shouldPan || !shouldSwipe
    }
}









