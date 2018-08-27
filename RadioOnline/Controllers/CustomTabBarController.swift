//
//  CustomTabBarController.swift
//  RadioOnline
//
//  Created by student on 8/20/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var radioSetter: RadioSetter?
    var VC: BarViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
         }

    
    //this method check tap on a tab bar controller
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        NotificationCenter.default.post(name: .clear, object: nil)
        if item.title != nil {
            DataManager.loadFavorites()
            NotificationCenter.default.post(name: .reloadFavoritesTableView, object: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if VC == nil{
//            VC = BarViewController()
//        }
//        radioSetter?.barViewController = VC
//        print(self.tabBar.frame.minY)
//        VC?.delegate = self
//        VC?.view.frame.size = CGSize(width: self.tabBar.frame.width, height: self.view.bounds.height * 0.08)
//        
//        let newView = VC?.view
//        
//        // newView?.frame.size = CGSize(width: self.tabBar.frame.width, height: self.view.bounds.height * 0.08)
//        newView?.frame.origin.y = self.tabBar.frame.minY - (newView?.frame.height)!
//        
//        self.view.addSubview(newView!)


    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if radioSetter == nil{
            radioSetter = RadioSetter()
            radioSetter?.setupRadio()
            
        }
        if VC == nil{
            VC = BarViewController()
        }
        VC?.delegate = self
        
        let newView = VC?.view
        
        newView?.frame.size = CGSize(width: self.tabBar.frame.width, height: self.view.frame.height * 0.08)
        newView?.frame.origin.y = self.tabBar.frame.minY - (newView?.frame.height)!
        self.view.addSubview(newView!)
        radioSetter?.barViewController = VC
        print(self.tabBar.frame.minY)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "RadioPlayer", let radioPlayerVC = segue.destination as? RadioPlayerViewController else { return }
        
    
        radioSetter?.radioPlayerViewController = radioPlayerVC
        radioPlayerVC.loadRadio(station: radioSetter?.radioPlayer?.station, track: radioSetter?.radioPlayer?.track)
    }

}


extension CustomTabBarController: BarViewControllerDelegate{
    func didPressPlayingButton() {
        radioSetter?.radioPlayer?.player.togglePlaying()
    }
    
    func didPressStopButton() {
        radioSetter?.radioPlayer?.player.stop()
    }
    
    func didPressNextButton() {
        
    }
    
    func didPressPreviousButton() {
        
    }
    
    func didTapped(sender: UITapGestureRecognizer) {
        if radioSetter?.radioPlayer?.station != nil{
        performSegue(withIdentifier: "RadioPlayer", sender: self)
        }
    }
    
}


