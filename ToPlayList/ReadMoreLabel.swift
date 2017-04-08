//
//  ReadMoreLabel.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 04. 08..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class ReadMoreLabel: UIStackView {

    private static let SHOW_MORE_TEXT = "Show more..."
    private static let SHOW_LESS_TEXT = "Show less..."
    
    private enum ButtonState {
        case showingMore
        case showingLess
    }
    
    private var buttonState = ButtonState.showingLess
    
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var showMoreButton: UIButton?
    
    @IBAction func showMoreButtonClicked(_ sender: Any) {
        switch buttonState {
        case .showingLess:
            showMore()
        case .showingMore:
            showLess()
        }
    }
    
    private func showMore() {
        buttonState = .showingMore
        showMoreButton?.setTitle(ReadMoreLabel.SHOW_LESS_TEXT, for: .normal)
        descriptionLabel?.numberOfLines = 0
    }
    
    private func showLess() {
        buttonState = .showingLess
        showMoreButton?.setTitle(ReadMoreLabel.SHOW_MORE_TEXT, for: .normal)
        descriptionLabel?.numberOfLines = 3
    }
}





