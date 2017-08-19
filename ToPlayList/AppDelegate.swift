//
//  AppDelegate.swift
//  ToPlayList
//
//  Created by Máthé Levente on 2016. 12. 21..
//  Copyright © 2016. Máthé Levente. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

extension UIColor {
    
    struct MyCustomColors {
        
        // these rgb values are different from storyboard, because UIColor init uses sRGB from iOS 10
        
        // FD9B40
        static var orange: UIColor {
            return UIColor(red: 255.0/255.0, green: 171.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        }
        
        static var red: UIColor {
            return UIColor(red: 255.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
    }
    
    var RGBA: RGBAComponents {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (r: red, g: green, b: blue, a: alpha)
    }
}

extension UIFont {
    
    struct MyFonts {
        
        static func avenirDefault(size: CGFloat) -> UIFont? {
            return UIFont(name: "Avenir Book", size: size)
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    override init() {
        super.init()
        //FIRDatabase.database().persistenceEnabled = true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        UNUserNotificationCenter.current().delegate = self
        
        setupTabBarAppearance()
        setupSearchBarAppearance()
        setupSegmentedControlAppearance()
        
        return true
    }
    
    static var appLaunchedWithNotifTappedForThisGame: String?
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let game = response.notification.request.content.userInfo[ToPlayListNotificationSystem.USER_INFO_GAME_KEY] as? String {
            AppDelegate.appLaunchedWithNotifTappedForThisGame = game
        }
        completionHandler()
    }
    
    private func setupTabBarAppearance() {
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.MyCustomColors.orange], for: .selected)
    }
    
    private func setupSearchBarAppearance() {
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSFontAttributeName : UIFont.MyFonts.avenirDefault(size: 17)!], for: .normal)
    }

    private func setupSegmentedControlAppearance() {
        UISegmentedControl.appearance().setTitleTextAttributes([NSFontAttributeName : UIFont.MyFonts.avenirDefault(size: 14)!], for: .normal)
    }
    
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        ToPlayListNotificationSystem.instance?.unlisten()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        //print("-----------entering foreground-------------")
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
            switch settings.authorizationStatus {
            case .authorized:
                //print("authorized")
                ToPlayListNotificationSystem.instance?.listen()
                ToPlayListNotificationSystem.instance?.permissionGranted = true
            case .denied:
                //print("denied")
                ToPlayListNotificationSystem.instance?.permissionGranted = false
            case .notDetermined:
                //print("not determined")
                ToPlayListNotificationSystem.instance?.permissionGranted = false
                break
            }
        })
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        ToPlayListNotificationSystem.instance?.unlisten()
    }
}

