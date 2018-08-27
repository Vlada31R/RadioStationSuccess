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
    @IBOutlet weak var button: UIButton!
    
    var arrayOfURLtoParse = [String]()
    var radioStationParse = [RadioStation]()
    var flagIsParse = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
        DataManager.changeColor(view: self.view)
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: .reload, object: nil)
        recolourAllElements()
    }
    
    //*******************************************************************************************************************************************
    //MARK: Recolour all elements (Chameleon framework)
    //*******************************************************************************************************************************************
    
    @objc func reload(notification: NSNotification){
        DataManager.changeColor(view: self.view)
        tableView.reloadData()
        recolourAllElements()
    }
    
    func recolourAllElements() {
        creteriaTextField.textColor = ContrastColorOf(creteriaTextField.backgroundColor!, returnFlat: true)
        creteriaTextField.layer.borderWidth = 2
        creteriaTextField.layer.cornerRadius = 6
        creteriaTextField.attributedPlaceholder = NSAttributedString(string:creteriaTextField.placeholder! , attributes:[NSAttributedStringKey.foregroundColor: ContrastColorOf(creteriaTextField.backgroundColor!, returnFlat: true)])
        creteriaTextField.layer.borderColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true).cgColor
        
        countTextField.layer.borderWidth = 2
        countTextField.layer.cornerRadius = 6
        countTextField.attributedPlaceholder = NSAttributedString(string:countTextField.placeholder! , attributes:[NSAttributedStringKey.foregroundColor: ContrastColorOf(countTextField.backgroundColor!, returnFlat: true)])
        countTextField.layer.borderColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true).cgColor
        countTextField.textColor = ContrastColorOf(countTextField.backgroundColor!, returnFlat: true)
        
        button.tintColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //*******************************************************************************************************************************************
    //MARK: Table View Methods
    //*******************************************************************************************************************************************
    func numberOfSections(in tableView: UITableView) -> Int {
        if radioStationParse.isEmpty && flagIsParse == true {
            let rect = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            let messageLabel = UILabel(frame: rect)
            messageLabel.text = "Radio station not found!"
            messageLabel.textColor = UIColor.black
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont(name: "TrebuchetMS", size: 20)
            messageLabel.sizeToFit()
            
            
            tableView.backgroundView = messageLabel
            tableView.separatorStyle = .none
            return 0
        } else {
            
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLineEtched
            return 1
        }
        
    }
    
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
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let tabBar = self.tabBarController as? CustomTabBarController{
            DataManager.preparePlayerTV(radioStation: radioStationParse[indexPath.row], tabBarController: self.tabBarController!)
        }
        if let tabBar = self.tabBarController as? CollectionTabBarController{
            DataManager.preparePlayerCV(radioStation: radioStationParse[indexPath.row], tabBarController: self.tabBarController!)
        }
    }
    
    //*******************************************************************************************************************************************
    //MARK: Parser action and function
    //*******************************************************************************************************************************************
    
    @IBAction func parse(_ sender: Any) {
        
        arrayOfURLtoParse.removeAll()
        radioStationParse.removeAll()
        countTextField.endEditing(true)
        creteriaTextField.endEditing(true)
        
        if let c = Int(countTextField.text!) {
            if c <= 0 || c > 1000 {
                ProgressHUD.show()
                ProgressHUD.showError("Please input new count")
                tableView.reloadData()
                return
            }
        } else {
            ProgressHUD.show()
            ProgressHUD.showError("Please input new count")
            tableView.reloadData()
            return
        }
        UIApplication.shared.beginIgnoringInteractionEvents()
        ProgressHUD.show("Please wait...")
        flagIsParse = true
        let count = Int(self.countTextField.text!)!
        let searchOld = self.creteriaTextField.text!
        
        let queue = OperationQueue()
        queue.addOperation() {

            var search = ""
            
            for i in searchOld{
                if i == " " {
                    search = search + "+"
                } else {
                    search = search + String(i)
                }
            }
        
            for i in 0...lroundf(Float(count)/30.0){
                self.parseAndGetArrayOfLink(search: search, pos:i*30)
            }
        
            if self.arrayOfURLtoParse.count > 0 {
        
                if count-1 < self.arrayOfURLtoParse.count {
                    var myArray = [String]()
            
                    for i in 0...count-1{
                        myArray.append(self.arrayOfURLtoParse[i])
                    }
                    self.arrayOfURLtoParse = myArray
                }
        
                for i in 0...self.arrayOfURLtoParse.count-1{
                    self.parse(myURL: self.arrayOfURLtoParse[i])
                    
                    OperationQueue.main.addOperation() {
                        self.tableView.reloadData()
                        let indexPath = IndexPath(row: self.radioStationParse.count-1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                        if i == self.arrayOfURLtoParse.count-1 {
                            ProgressHUD.dismiss()
                            UIApplication.shared.endIgnoringInteractionEvents()
                        }
                    }
            }
            } else {
                OperationQueue.main.addOperation() {
                    self.tableView.reloadData()
                    ProgressHUD.dismiss()
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
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
        //check have station name and url
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
        } catch let error {
            print("Error: \(error)")
        }
        //pars string url
        do{
            let doc = try SwiftSoup.parse(myHTMLString)
            do{
                let element = try doc.select("a").array()
                
                do{
                    if 7 > element.count-5 {
                        return
                    }
                    for i in 7...element.count-5{
                        arrayOfURLtoParse.append(try element[i].attr("href"))
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

