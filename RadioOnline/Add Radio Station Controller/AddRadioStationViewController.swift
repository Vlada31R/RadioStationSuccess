//
//  AddRadioStationViewController.swift
//  RadioOnline
//
//  Created by student on 8/20/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import ChameleonFramework

class AddRadioStationViewController: UIViewController {
    


    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var URLStreamTextField: UITextField!
    @IBOutlet weak var URLImageTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var urlStreamLabel: UILabel!
    @IBOutlet weak var urlImgLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.changeColor(view: self.view)
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: .reload, object: nil)
        recolourAllElements()
    }
    
    @objc func reload(notification: NSNotification){
        DataManager.changeColor(view: self.view)
        recolourAllElements()
    }
    
    func recolourAllElements() {
        nameLabel.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
        descLabel.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
        urlStreamLabel.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
        urlImgLabel.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
        
        nameTextField.layer.borderWidth = 2
        nameTextField.layer.cornerRadius = 10
        nameTextField.layer.borderColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true).cgColor
        descriptionTextField.layer.borderWidth = 2
        descriptionTextField.layer.cornerRadius = 10
        descriptionTextField.layer.borderColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true).cgColor
        URLStreamTextField.layer.borderWidth = 2
        URLStreamTextField.layer.cornerRadius = 10
        URLStreamTextField.layer.borderColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true).cgColor
        URLImageTextField.layer.borderWidth = 2
        URLImageTextField.layer.cornerRadius = 10
        URLImageTextField.layer.borderColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true).cgColor
        
        nameTextField.textColor = ContrastColorOf(nameTextField.backgroundColor!, returnFlat: true)
        descriptionTextField.textColor = ContrastColorOf(descriptionTextField.backgroundColor!, returnFlat: true)
        URLStreamTextField.textColor = ContrastColorOf(URLStreamTextField.backgroundColor!, returnFlat: true)
        URLImageTextField.textColor = ContrastColorOf(URLImageTextField.backgroundColor!, returnFlat: true)
        
        button.tintColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
   
    @IBAction func addNewRadioStation(_ sender: Any) {
        let name = nameTextField.text!
        let desc = descriptionTextField.text!
        let urlStream = URLStreamTextField.text!
        let urlImage = URLImageTextField.text!
        if name.count > 0 && urlStream.count > 0 {
            DataManager.addNewRadioStation(name: name, desc: desc, urlStream: urlStream, urlImage: urlImage)
            NotificationCenter.default.post(name: .reload, object: nil)
            let alert = UIAlertController(title: "Radiostation add all station!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Sorry... some error, please retry!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    


}
