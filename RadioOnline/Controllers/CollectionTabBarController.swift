//
//  CollectionTabBarController.swift
//  RadioOnline
//
//  Created by student on 8/20/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class CollectionTabBarController: UITabBarController, UITabBarControllerDelegate {

    var playingBar: PlayingBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playingBar = PlayingBar.init(frame: CGRect(x: 0, y: self.tabBar.frame.minY - 50, width: self.view.frame.width, height: 50))
        self.view.addSubview(playingBar)
    }
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "All" {
            DataManager.loadFavorites()
            NotificationCenter.default.post(name: .reloadFavourites, object: nil)
        }
    }
}
