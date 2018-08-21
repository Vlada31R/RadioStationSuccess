//
//  ParserViewController.swift
//  RadioOnline
//
//  Created by student on 8/21/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import ChameleonFramework
import SwiftSoup
import ProgressHUD

class ParserViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var creteriaTextField: UITextField!
    @IBOutlet weak var countTextField: UITextField!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tabBarItem.
        //self.navigationItem.hidesBackButton = true
        
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //*******************************************************************************************************************************************
    //MARK: Table View Methods
    //*******************************************************************************************************************************************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return radioStationParse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        cell.backgroundColor = self.view.backgroundColor
        cell.nameLabel.text = radioStationParse[indexPath.row].name
        cell.nameLabel.textColor = ContrastColorOf(tableView.backgroundColor!, returnFlat: true)
        cell.descriptionLabel.text = radioStationParse[indexPath.row].desc
        cell.descriptionLabel.textColor = ContrastColorOf(tableView.backgroundColor!, returnFlat: true)
        
        let img = DataManager.readImg(name: "\(radioStationParse[indexPath.row].name).png")
        if img == nil || img == #imageLiteral(resourceName: "stationImage") {
            cell.imageRadioStation.downloadedFrom(link: radioStationParse[indexPath.row].imageURL, name: "\(radioStationParse[indexPath.row].name).png")
        } else {
            cell.imageRadioStation.image = img
            //print("image load from device")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //*******************************************************************************************************************************************
    //MARK: Parser action and function
    //*******************************************************************************************************************************************
    
    var arrayOfURLtoParse = [String]()
    var radioStationParse = [RadioStation]()
    
    @IBAction func parse(_ sender: Any) {
        arrayOfURLtoParse.removeAll()
        countTextField.endEditing(true)
        creteriaTextField.endEditing(true)
        
        let count = Int(countTextField.text!)!
        let searchOld = creteriaTextField.text!
        var search = ""
        
        for i in searchOld{
            if i == " " {
                search = search + "+"
            } else {
                search = search + String(i)
            }
        }
        
        for i in 0...lroundf(Float(count)/30.0){
            parseAndGetArrayOfLink(search: search, pos:i*30)
        }
        
        
        var myArray = [String]()
        for i in 0...count-1{
            myArray.append(arrayOfURLtoParse[i])
        }
        
        arrayOfURLtoParse = myArray
        
        
        ProgressHUD.show("Please wait...")
        self.navigationItem.backBarButtonItem?.isEnabled = false
        //self.navigationItem.leftBarButtonItem.enabled = false
        let queue = OperationQueue()
        
        queue.addOperation() {
            // do something in the background
            for i in 0...self.arrayOfURLtoParse.count-1{
                self.parse(myURL: self.arrayOfURLtoParse[i])
                print("\(i) finish")
            }
            OperationQueue.main.addOperation() {
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                self.navigationItem.backBarButtonItem?.isEnabled = true
                // when done, update your UI and/or model on the main queue
            }
        }
        
        
        
    }
    
    
    //parser start
    //this function purse one radiostation from array arrayOfURLtoParse
    func parse(myURL: String){
        var name: String?
        var desc: String?
        var url: String?
        //transform url to string
        var myHTMLString = ""
        let myURLString = "http://www.radiosure.com/rsdbms/\(myURL)"
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return
        }
        
        do {
            myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            //print("HTML : in string save")
        } catch let error {
            print("Error: \(error)")
        }
        //parse
        do{
            let doc = try SwiftSoup.parse(myHTMLString)
            do{
                let element = try doc.select("td").array()
                
                do{
                    name = try element[3].text()
                    desc = try element[7].text()
                    url = try element[15].text()
                } catch {
                    print("error get text")
                }
                
            }catch{
                
            }
            
        } catch {
            
        }
        //sheck have station name and url
        if name != nil && url != nil {
            let a = RadioStation(name: name!, streamURL: url!, imageURL: "", desc: desc!, longDesc: "", favorites: false, new: false)
            radioStationParse.append(a)
        } else {
            print("error name or url is nil")
        }
    }
    
    //this function collect url radiostation
    func parseAndGetArrayOfLink(search: String, pos: Int){
        //transform url to string
        var myHTMLString = ""
        let myURLString = "http://www.radiosure.com/rsdbms/search.php?status=active&search=\(search)&pos=\(pos)&reset_pos=0#info"
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return
        }
        
        do {
            myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            //print("HTML : in string save")
        } catch let error {
            print("Error: \(error)")
        }
        //pars string url
        do{
            let doc = try SwiftSoup.parse(myHTMLString)
            do{
                let element = try doc.select("a").array()
                
                do{
                    for i in 7...element.count-5{
                        arrayOfURLtoParse.append(try element[i].attr("href"))
                        //print(try element[i].attr("href")+"\(i) \n")
                    }
                    
                    
                } catch {
                    print("error get text")
                }
                
            }catch{
                
            }
            
        } catch {
            
        }
    }
    
    //perser finish
    
    //*******************************************************************************************************************************************
    //MARK: tableView cell swipe
    //*******************************************************************************************************************************************
    @available(iOS 9.0, *)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let share = UITableViewRowAction(style: .normal, title: "           ") { action, index in
            
            if DataManager.addNewStationFromParser(station: self.radioStationParse[indexPath.row]) {
                ProgressHUD.show()
                ProgressHUD.showSuccess("Radio station added to all radio station!")
                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                NotificationCenter.default.post(name: .reload, object: nil)
            } else {
                ProgressHUD.show()
                ProgressHUD.showError("Radio station not added to all radio station, because you have this stream url in all station!")
                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
        }
        share.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "downloadForios9"))

        return [share]
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let flagAction = self.contextualToggleFlagAction(forRowAtIndexPath: indexPath)
        
            flagAction.backgroundColor = UIColor.green
        
        let swipeConfig = UISwipeActionsConfiguration(actions: [flagAction])
        return swipeConfig
    }
    
    @available(iOS 11.0, *)
    func contextualToggleFlagAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Add") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            if self.addToAllStation(indexPath) {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
        action.image = UIImage(named: "download")
        return action
    }
    
    @available(iOS 11.0, *)
    func addToAllStation(_ indexPath: IndexPath) -> Bool{
        if DataManager.addNewStationFromParser(station: radioStationParse[indexPath.row]) {
            ProgressHUD.show()
            ProgressHUD.showSuccess("Radio station added to all radio station!")
            NotificationCenter.default.post(name: .reload, object: nil)
            return true
        } else {
            ProgressHUD.show()
            ProgressHUD.showError("Radio station not added to all radio station, because you have this stream url in all station!")
            return false
        }
        
    }
    
    //*******************************************************************************************************************************************
    //MARK: Touches function
    //*******************************************************************************************************************************************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        countTextField.endEditing(true)
        creteriaTextField.endEditing(true)
    }
}

