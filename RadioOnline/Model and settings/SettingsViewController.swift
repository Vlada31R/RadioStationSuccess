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
    
}
