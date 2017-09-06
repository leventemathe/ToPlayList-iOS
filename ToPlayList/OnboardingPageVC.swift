//
//  OnboardingPageVC.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2017. 08. 30..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit

class OnboardingPageVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var vcs = [UIViewController]()
    
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        dataSource = self
        delegate = self
        setupVCs()
    }
    
    private func setupVCs() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let vcDetailsA1 = storyboard.instantiateViewController(withIdentifier: "OnboardingDetailsVCA") as! OnboardingDetailsVC
        let vcDetailsA2 = storyboard.instantiateViewController(withIdentifier: "OnboardingDetailsVCA") as! OnboardingDetailsVC
        let vcDetailsB1 = storyboard.instantiateViewController(withIdentifier: "OnboardingDetailsVCB") as! OnboardingDetailsVC
        let vcDetailsB2 = storyboard.instantiateViewController(withIdentifier: "OnboardingDetailsVCB") as! OnboardingDetailsVC
        let vcDetailsB3 = storyboard.instantiateViewController(withIdentifier: "OnboardingDetailsVCB") as! OnboardingDetailsVC
        let vcDetailsB4 = storyboard.instantiateViewController(withIdentifier: "OnboardingDetailsVCB") as! OnboardingDetailsVC
        
        vcDetailsA1.setup(iphoneImage: #imageLiteral(resourceName: "onb_phone_discover"), title: "Discover", text: "Discover new games by browsing the newest or upcoming releases. You can also search for specific games.", backgroundFlipped: true)
        vcDetailsA2.setup(iphoneImage: #imageLiteral(resourceName: "onb_phone_lists"), title: "Lists & Notifications", text: "After a quick registration process, you'll have two lists in the Lists view: ToPlay and Played list. You can get notifications when a game on your ToPlay list is released.", backgroundFlipped: true)
        vcDetailsB1.setup(iphoneImage: #imageLiteral(resourceName: "onb_phone_stars"), title: "Stars represent lists", text: "A star displayed next to a game means it’s on a list. An unfilled star represents the ToPlay list, while a filled star means the game is on the Played list.")
        vcDetailsB2.setup(iphoneImage: #imageLiteral(resourceName: "onb_phone_releases_swipe"), title: "Swipe in releases", text: "Swiping a game left or right will add it to a list: swipe left to add to the ToPlay list, or right to add it to the Played list.")
        vcDetailsB3.setup(iphoneImage: #imageLiteral(resourceName: "onb_phone_details_swipe"), title: "Swipe in the details view", text: "Add a game to a list in the details view by swiping the game cover. Notice the unfilled star on the screenshot: we’re moving the game from the ToPlay list to the Played list.")
        vcDetailsB4.setup(iphoneImage: #imageLiteral(resourceName: "onb_phone_manage_lists"), title: "Managing Lists", text: "In the Lists view you can manage your ToPlay and Played list. To move a game from one list to the other, swipe it in the direction of the other list. If you want to remove a game, just swipe it in the opposite direction.")
        vcDetailsB4.lastVCInPageVC = true
        vcs = [vcDetailsA1, vcDetailsA2, vcDetailsB1, vcDetailsB2, vcDetailsB3, vcDetailsB4]
        setViewControllers([vcs[0]], direction: .forward, animated: true, completion: nil)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return vcs.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return getNextVC(ofCurrentVC: viewController, withNextSelector: { $0-1 })
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return getNextVC(ofCurrentVC: viewController, withNextSelector: { $0+1 })
    }
    
    private func getNextVC(ofCurrentVC vc: UIViewController, withNextSelector nextSelector: (Int)->Int) -> UIViewController? {
        guard let currentIndex = vcs.index(of: vc) else {
            return nil
        }
        
        self.currentIndex = currentIndex
        let nextIndex = nextSelector(currentIndex)
        if nextIndex >= 0 && vcs.count > nextIndex {
            return vcs[nextIndex]
        }
        
        return nil
    }
}
