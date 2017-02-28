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
        case .played:
            setStarToPlayed()
        case .none:
            setStarToNone()
        }
    }
    
    // SWIPING
    
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var toPlay: UILabel!
    @IBOutlet weak var played: UILabel!
    
    @IBOutlet weak var contentLeading: NSLayoutConstraint!
    @IBOutlet weak var contentTrailing: NSLayoutConstraint!
    
    private var contentLeadingStartingConstant: CGFloat!
    private var contentTrailingStartingConstant: CGFloat!
    
    private var toPlayStartingColor: UIColor!
    private var playedStartingColor: UIColor!
    private var toPlayTargetColor = UIColor.MyCustomColors.orange
    private var playedTargetColor = UIColor.blue
    
    private var panRecognizer: UIPanGestureRecognizer!
    private var panStartPoint: CGPoint!
    private var shouldPan = false
    
    var networkErrorHandlerDelegate: ErrorHandlerDelegate?
    
    override func awakeFromNib() {
        contentLeadingStartingConstant = contentLeading.constant
        contentTrailingStartingConstant = contentTrailing.constant
        
        toPlayStartingColor = toPlay.backgroundColor
        playedStartingColor = played.backgroundColor
        
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
        
        let currentPoint = panRecognizer.translation(in: content)
        let newPosX = currentPoint.x - panStartPoint.x
        moveContent(newPosX)
        
        let progress: CGFloat = newPosX < 0.0 ? contentTrailing.constant / rightBackgroundEdge : contentLeading.constant / leftBackgroundEdge
        changeColorLeft(progress)
        changeColorRight(progress)
    }
    
    private func panEnded() {
        shouldPan = false
        addGameToList()
        panEndedAnimation()
    }
    
    private func addGameToList() {
        if contentLeading.constant >= leftBackgroundEdge {
            addGameToToPlayList()
        } else if contentTrailing.constant >= rightBackgroundEdge {
            addGameToPlayedList()
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
        }, completion: { completed in
            if completed {
                self.resetColorLeftRight()
            }
        })
    }
    
    private var leftBackgroundEdge: CGFloat {
        return toPlay.frame.size.width
    }
    
    private var rightBackgroundEdge: CGFloat {
        return played.frame.size.width
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
    
    private func changeColorLeft(_ progress: CGFloat) {
        let start: RGBAComponents = toPlayStartingColor.RGBA
        let target: RGBAComponents = toPlayTargetColor.RGBA
        let new: RGBAComponents = (r: (1.0-progress)*start.r + progress*target.r, g: (1.0-progress)*start.g + progress*target.g, b: (1.0-progress)*start.b + progress*target.b, a: 1.0)
        
        toPlay.backgroundColor = UIColor(red: new.r, green: new.g, blue: new.b, alpha: new.a)
    }
    
    private func changeColorRight(_ progress: CGFloat) {
        let start: RGBAComponents = playedStartingColor.RGBA
        let target: RGBAComponents = playedTargetColor.RGBA
        let new: RGBAComponents = (r: (1.0-progress)*start.r + progress*target.r, g: (1.0-progress)*start.g + progress*target.g, b: (1.0-progress)*start.b + progress*target.b, a: 1.0)
        
        played.backgroundColor = UIColor(red: new.r, green: new.g, blue: new.b, alpha: new.a)
    }
    
    private func resetColorLeftRight() {
        toPlay.backgroundColor = toPlayStartingColor
        played.backgroundColor = playedStartingColor
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !shouldPan
    }
}









