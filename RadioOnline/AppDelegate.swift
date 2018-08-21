//
//  AppDelegate.swift
//  RadioOnline
//
//  Created by student on 8/14/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        
//        let initialViewController = storyboard.instantiateViewController(withIdentifier: "AllVC")
//        
//        self.window?.rootViewController = initialViewController
//        self.window?.makeKeyAndVisible()
        //make bandge
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let userDefaults = UserDefaults.standard
        var viewController : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TableVC") as! UITabBarController
        if let mode = userDefaults.string(forKey: "mode")
        {
            if mode == "collection"
            {
                viewController = mainStoryboard.instantiateViewController(withIdentifier: "AllVC") as! UITabBarController
                
            }
            else if mode == "list"
            {
                viewController = mainStoryboard.instantiateViewController(withIdentifier: "TableVC") as! UITabBarController
            }
            
        }
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
        
        DataManager.load()
        DataManager.loadFavorites()
        // MPNowPlayingInfoCenter
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        
        // FRadioPlayer config
        FRadioPlayer.shared.isAutoPlay = true
        FRadioPlayer.shared.enableArtwork = true
        FRadioPlayer.shared.artworkSize = 600
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        DataManager.save()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        DataManager.load()
        DataManager.loadFavorites()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        DataManager.save()
        UIApplication.shared.endReceivingRemoteControlEvents()

    }
    
    // MARK: - Remote Controls
    
    override func remoteControlReceived(with event: UIEvent?) {
        super.remoteControlReceived(with: event)
        
        guard let event = event, event.type == UIEventType.remoteControl else { return }
        
        switch event.subtype {
        case .remoteControlPlay:
            FRadioPlayer.shared.play()
        case .remoteControlPause:
            FRadioPlayer.shared.pause()
        case .remoteControlTogglePlayPause:
            FRadioPlayer.shared.togglePlaying()
        default:
            break
        }
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                         open: url,
                                                         sourceApplication: sourceApplication,
                                                         annotation: annotation)
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any]) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, options: options)
    }

}

