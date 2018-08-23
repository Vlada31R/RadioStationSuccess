//
//  CollectionTabBarController.swift
//  RadioOnline
//
//  Created by student on 8/20/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit



class CollectionTabBarController: UITabBarController, UITabBarControllerDelegate {


    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title != nil {
            DataManager.load()
            DataManager.loadFavorites()
            NotificationCenter.default.post(name: .reloadFavourites, object: nil)
        }
        
        

    }
}
