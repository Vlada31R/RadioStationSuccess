//
//  CustomTabBarController.swift
//  RadioOnline
//
//  Created by student on 8/20/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var radioSetter = RadioSetter()
    var VC = BarViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VC.delegate = self
        radioSetter.setupRadio()
        
        let newView = VC.view
        newView?.frame.origin.y = self.tabBar.frame.minY - (newView?.frame.height)!
        self.view.addSubview(newView!)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "RadioPlayer", let radioPlayerVC = segue.destination as? RadioPlayerViewController else { return }
        
        let newStation: Bool = true
    
        radioSetter.radioPlayerViewController = radioPlayerVC
        radioPlayerVC.loadRadio(station: radioSetter.radioPlayer?.station, track: radioSetter.radioPlayer?.track, isNew: newStation)
    }

}


extension CustomTabBarController: BarViewControllerDelegate{
    func didTapped(sender: UITapGestureRecognizer) {

        performSegue(withIdentifier: "RadioPlayer", sender: self)
    }
}
