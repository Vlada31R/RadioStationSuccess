//
//  CollectionTabBarController.swift
//  RadioOnline
//
//  Created by student on 8/20/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit



class CollectionTabBarController: UITabBarController, UITabBarControllerDelegate {

    var radioSetter: RadioSetter?
    var VC: BarViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title != nil {
            DataManager.load()
            DataManager.loadFavorites()
            NotificationCenter.default.post(name: .reloadFavourites, object: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "RadioPlayer", let radioPlayerVC = segue.destination as? RadioPlayerViewController else { return }
        
        radioSetter?.radioPlayerViewController = radioPlayerVC
        radioPlayerVC.loadRadio(station: radioSetter?.radioPlayer?.station, track: radioSetter?.radioPlayer?.track)
    }
    
    func changeMetadata(image: UIImage, song: String, artist: String){
        VC?.albumImage.image = image
        VC?.songLabel.text = song
        VC?.artistLabel.text = artist
    }
}

extension CollectionTabBarController: BarViewControllerDelegate{
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
        
        performSegue(withIdentifier: "RadioPlayer", sender: self)
    }
    
}
