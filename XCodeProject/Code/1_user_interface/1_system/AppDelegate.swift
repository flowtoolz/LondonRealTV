//
//  AppDelegate.swift
//  LondonRealTV
//
//  Created by Sebastian Fichtner on 01/10/15.
//  Copyright © 2015 Flowtoolz. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate
{
    // MARK: App Life Cycle
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool
    {
        //FIRApp.configure()
        
        initialize()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = tabViewController
        window!.makeKeyAndVisible()
        
        return true
    }
    
    func initialize()
    {
        UserInterfaceModel.makeSureInstanceExists()
        UseCasesSystem.makeSureInstanceExists()
    }

    var window: UIWindow?
    
    func applicationDidBecomeActive(_ application: UIApplication)
    {
        DomainModel.sharedInstance.loadVideos()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication)
    {
    }
    
    // MARK: Topshelf

    func application(_ app: UIApplication,
        open url: URL,
        options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        guard let query = url.queryDictionary(),
            let title = query["title"]
        else
        {
            return false
        }
        
        episodeListViewController.playVideoWithTitle(title)
        
        return true
    }

    // MARK: View Controllers
    
    lazy var tabViewController: UITabBarController =
    {
        let vc = UITabBarController()
        
        // add view controllers
        let viewControllers = [self.episodeListViewController,
            AboutViewController(),
            FeedbackViewController()];
        
        vc.setViewControllers(viewControllers, animated: false)
        
        // style
        vc.tabBar.barTintColor = UIColor.white
        vc.tabBar.isTranslucent = false
        vc.tabBar.tintColor = UIColor.LondonRealFocusedText()
        UITabBarItem.appearance().setTitleTextAttributes([NSFontAttributeName:UIFont.LondonRealHeadline()],
            for: UIControlState())

        return vc
    }()

    let episodeListViewController = VideoTableViewController()
}
