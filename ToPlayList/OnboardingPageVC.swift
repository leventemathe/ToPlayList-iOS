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
        let vcOverView = storyboard.instantiateViewController(withIdentifier: "OnboardingOverviewVC") as! OnboardingOverviewVC
        let vcDetails1 = storyboard.instantiateViewController(withIdentifier: "OnboardingDetailsVC") as! OnboardingDetailsVC
        let vcDetails2 = storyboard.instantiateViewController(withIdentifier: "OnboardingDetailsVC") as! OnboardingDetailsVC
        let vcDetails3 = storyboard.instantiateViewController(withIdentifier: "OnboardingDetailsVC") as! OnboardingDetailsVC
        
        vcDetails1.setup(iphoneImage: #imageLiteral(resourceName: "onb_phone_stars"), title: "Stars represent lists", text: "A star displayed next to a game means it’s in a list. An unfilled star represents the ToPlay list, while a filled star means the game is in the Played list.")
        vcDetails2.setup(iphoneImage: #imageLiteral(resourceName: "onb_phone_lists"), title: "Managing Lists", text: "In the lists view you can manage your ToPlay and Played list. To move a game from one list to the other, swipe it in the direction of the other list. If you want to remove a game, swipe it in the opposite direction.")
        vcDetails3.setup(iphoneImage: #imageLiteral(resourceName: "onb_phone_swipe"), title: "Swipe to add to a list", text: "Swiping a game left or right will add it to a list. You can do this in all views: swipe left to add to ToPlay, right to add to Played in one of the releases views, or swipe the game cover in the details view.")
        vcDetails3.lastVCInPageVC = true
        vcs = [vcOverView, vcDetails1, vcDetails2, vcDetails3]
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
