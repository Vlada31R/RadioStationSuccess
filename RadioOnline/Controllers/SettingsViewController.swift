//
//  SettingsViewController.swift
//  RadioOnline
//
//  Created by student on 8/16/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import ChameleonFramework

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var upView: UIView!
    
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    
    @IBOutlet weak var collection: UIButton!
    @IBOutlet weak var list: UIButton!
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = UserDefaults.standard
        if let mode = userDefaults.string(forKey: "mode")
        {
            if mode == "collection"
            {
                collection.isSelected = true
            }
            else if mode == "list"
            {
                list.isSelected = true
            }
        }
        
        collection.setImage(UIImage(named: "collection"), for: .normal)
        list.setImage(UIImage(named: "list"), for: .normal)
        
        DataManager.changeColor(view: self.view)
        upView.backgroundColor = self.view.backgroundColor
        modeLabel.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
        colorLabel.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
        
        let colour = self.view.backgroundColor
        let rgbColour = colour?.cgColor
        let rgbColours = rgbColour?.components
        
        redSlider.value = Float(rgbColours![0])
        greenSlider.value = Float(rgbColours![1])
        blueSlider.value = Float(rgbColours![2])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tabBarVC = self.tabBarController as? CustomTabBarController{
            tabBarVC.VC?.view.isHidden = true
        }
        if let tabBarVC = self.tabBarController as? CollectionTabBarController{
            tabBarVC.VC?.view.isHidden = true
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let tabBarVC = self.tabBarController as? CustomTabBarController{
        tabBarVC.VC?.view.isHidden = false
        }
        if let tabBarVC = self.tabBarController as? CollectionTabBarController{
            tabBarVC.VC?.view.isHidden = false
        }
    }
    @IBAction func sliderValueChanged(_ sender: Any) {
        let redInfo=CGFloat(redSlider.value)
        let greenInfo=CGFloat(greenSlider.value)
        let blueInfo=CGFloat(blueSlider.value)
        
        self.view.backgroundColor = UIColor(red: CGFloat(redSlider.value), green: CGFloat(greenSlider.value), blue: CGFloat(blueSlider.value), alpha: 1.0)
        upView.backgroundColor = UIColor(red: CGFloat(redSlider.value), green: CGFloat(greenSlider.value), blue: CGFloat(blueSlider.value), alpha: 1.0)
        
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(redInfo, forKey: "redInfo")
        userDefaults.setValue(greenInfo, forKey: "greenInfo")
        userDefaults.setValue(blueInfo, forKey: "blueInfo")
        modeLabel.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
        colorLabel.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
        
        NotificationCenter.default.post(name: .reload, object: nil)
    }
    @IBAction func listButtonClicked(_ sender: Any) {
        list.isSelected = true
        collection.isSelected = false
        setMode(mode: "list", identifier: "TableVC")
    }
    @IBAction func collectionButtonClicked(_ sender: Any) {
        collection.isSelected = true
        list.isSelected = false
        setMode(mode: "collection", identifier: "AllVC")
    }
    func setMode(mode: String, identifier : String) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(mode, forKey: "mode")
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let tabController = mainStoryboard.instantiateViewController(withIdentifier: identifier) as! UITabBarController
        
        UIApplication.shared.keyWindow?.rootViewController = tabController
        
      if let newTabBar = tabController as? CollectionTabBarController{
        if let myTabBar = self.tabBarController as? CustomTabBarController{
            newTabBar.radioSetter = myTabBar.radioSetter!
            newTabBar.VC?.playingTrack = myTabBar.VC?.playingTrack
            newTabBar.VC?.playingStation = myTabBar.VC?.playingStation
            newTabBar.VC = myTabBar.VC
            newTabBar.VC?.delegate = newTabBar

            newTabBar.VC?.updateLabels()
            newTabBar.VC?.updateTrackArtwork(with: myTabBar.VC?.playingTrack)
            newTabBar.VC?.updateTrackMetadata(with: myTabBar.VC?.playingTrack)
            newTabBar.VC?.playerStateDidChange((myTabBar.radioSetter?.radioPlayer?.player.state)!)
            newTabBar.VC?.playbackStateDidChange((myTabBar.radioSetter?.radioPlayer?.player.playbackState)!)
        }}

        if let newTabBar = tabController as? CustomTabBarController{
            if let myTabBar = self.tabBarController as? CollectionTabBarController{
                newTabBar.radioSetter = myTabBar.radioSetter!
                newTabBar.VC?.playingTrack = myTabBar.VC?.playingTrack
                newTabBar.VC?.playingStation = myTabBar.VC?.playingStation
                newTabBar.VC = myTabBar.VC
                newTabBar.VC?.delegate = newTabBar

                newTabBar.VC?.updateLabels()
                newTabBar.VC?.updateTrackArtwork(with: myTabBar.VC?.playingTrack)
                newTabBar.VC?.updateTrackMetadata(with: myTabBar.VC?.playingTrack)
                newTabBar.VC?.playerStateDidChange((myTabBar.radioSetter?.radioPlayer?.player.state)!)
                newTabBar.VC?.playbackStateDidChange((myTabBar.radioSetter?.radioPlayer?.player.playbackState)!)
            }}
    }
    
}
