//
//  CustomTabBarController.swift
//  RadioOnline
//
//  Created by student on 8/20/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    //this method check tap on a tab bar controller
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title != nil {
            DataManager.loadFavorites()
            NotificationCenter.default.post(name: .reloadFavoritesTableView, object: nil)
        }
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
