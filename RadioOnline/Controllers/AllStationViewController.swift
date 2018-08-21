    //
//  AllStationViewController.swift
//  RadioOnline
//
//  Created by student on 8/15/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import ChameleonFramework
import ProgressHUD
import SwiftSoup
    

class AllStationViewController:  UIViewController,  UITableViewDelegate, UITableViewDataSource {
    //parser start
    func parse(){
        var name: String?
        var desc: String?
        var url: String?
        var myHTMLString = ""
        let myURLString = "http://www.radiosure.com/rsdbms/details.php?id=150604#info"
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return
        }
        
        do {
            myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            print("HTML : in string save")
        } catch let error {
            print("Error: \(error)")
        }
        
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
        print(name,desc,url)
    }
    var arrayOfURLtoParse = [String]()
    func parseAndGetArrayOfLink(pos: Int){
        let search = ""
        //let pos = 0
        
        var myHTMLString = ""
        let myURLString = "http://www.radiosure.com/rsdbms/search.php?status=active&search=\(search)&pos=\(pos)&reset_pos=0#info"
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return
        }
        
        do {
            myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
            print("HTML : in string save")
        } catch let error {
            print("Error: \(error)")
        }
        
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
    
    @IBOutlet var tableView: UITableView!
    
    var radioSetter = RadioSetter()
    
    //*****************************************************************
    // MARK: - viewDidLoad Method
    //*****************************************************************
    override func viewDidLoad() {
        let count = 15
        for i in 0...lroundf(Float(count)/30.0){
            parseAndGetArrayOfLink(pos:i*30)//parser function
        }
        print(arrayOfURLtoParse.count)
        var myArray = [String]()
        for i in 0...count-1{
            myArray.append(arrayOfURLtoParse[i])
        }
        print(myArray.count)
        
        
        super.viewDidLoad()
        radioSetter.setupRadio()
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
        DataManager.changeColor(view: self.view)
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: .reload, object: nil)
        DataManager.updateBandge(TabItems: self.tabBarController?.tabBar.items as NSArray?)
    }
    
    @objc func reload(notification: NSNotification){
        DataManager.changeColor(view: self.view)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //*******************************************************************************************************************************************
    //MARK: tableView method
    //*******************************************************************************************************************************************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(DataManager.stations.count)
        return (DataManager.stations.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        cell.backgroundColor = self.view.backgroundColor
        cell.nameLabel.text = DataManager.stations[indexPath.row].name
        cell.nameLabel.textColor = ContrastColorOf(tableView.backgroundColor!, returnFlat: true)
        cell.descriptionLabel.text = DataManager.stations[indexPath.row].desc
        cell.descriptionLabel.textColor = ContrastColorOf(tableView.backgroundColor!, returnFlat: true)
        //check image in device and load from device or internet
        let img = DataManager.readImg(name: "\(DataManager.stations[indexPath.row].name).png")
        if img == nil || img == #imageLiteral(resourceName: "stationImage") {
            cell.imageRadioStation.downloadedFrom(link: DataManager.stations[indexPath.row].imageURL, name: "\(DataManager.stations[indexPath.row].name).png")
        } else {
            cell.imageRadioStation.image = img
            //print("image load from device")
        }
        
        return cell
    }
    
    //*******************************************************************************************************************************************
    //MARK: tableView cell swipe
    //*******************************************************************************************************************************************
    @available(iOS 9.0, *)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let share = UITableViewRowAction(style: .normal, title: "           ") { action, index in
            if DataManager.stations[indexPath.row].favorites == true {
                DataManager.stations[indexPath.row].favorites = false
                DataManager.stations[indexPath.row].new = false
                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.middle)
                ProgressHUD.show()
                ProgressHUD.showError("Radio station removed from favorites!")
            } else {
                DataManager.stations[indexPath.row].favorites = true
                DataManager.stations[indexPath.row].new = true
                tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.middle)
                ProgressHUD.show()
                ProgressHUD.showSuccess("Radio station add to favorites!")
            }
            DataManager.loadFavorites()
            DataManager.updateBandge(TabItems: self.tabBarController?.tabBar.items as NSArray?)
            NotificationCenter.default.post(name: .reloadFavoritesTableView, object: nil)
        }
        if DataManager.stations[indexPath.row].favorites == true {
            share.backgroundColor = .orange
        } else {
            share.backgroundColor = .gray
        }
        
        share.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "favoritesForIOS9"))
        
        
        
        return [share]
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let flagAction = self.contextualToggleFlagAction(forRowAtIndexPath: indexPath)
        if DataManager.stations[indexPath.row].favorites == true {
            flagAction.backgroundColor = UIColor.orange
        } else {
            flagAction.backgroundColor = UIColor.gray
        }
        let swipeConfig = UISwipeActionsConfiguration(actions: [flagAction])
        return swipeConfig
    }
    
    @available(iOS 11.0, *)
    func contextualToggleFlagAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Flag") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            if self.addFavorites(indexPath) {
                completionHandler(true)
            } else {
                completionHandler(false)
            }
        }
        action.image = UIImage(named: "favorites")
        return action
    }
    
    @available(iOS 11.0, *)
    func addFavorites(_ indexPath: IndexPath) -> Bool{
        if DataManager.stations[indexPath.row].favorites == true {
            DataManager.stations[indexPath.row].favorites = false
            DataManager.stations[indexPath.row].new = false
            ProgressHUD.show()
            ProgressHUD.showError("Radio station removed from favorites!")
        } else {
            DataManager.stations[indexPath.row].favorites = true
            DataManager.stations[indexPath.row].new = true
            ProgressHUD.show()
            ProgressHUD.showSuccess("Radio station add to favorites!")
        }
        DataManager.loadFavorites()
        DataManager.updateBandge(TabItems: self.tabBarController?.tabBar.items as NSArray?)
        NotificationCenter.default.post(name: .reloadFavoritesTableView, object: nil)
        return true
    }
    
    //*******************************************************************************************************************************************
    //MARK: segue to collectionView
    //*******************************************************************************************************************************************
    
    @IBAction func action(_ sender: Any) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "AllVC") as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "RadioPlayer", let radioPlayerVC = segue.destination as? RadioPlayerViewController else { return }
        
        
        let newStation: Bool
        
        if let indexPath = (sender as? IndexPath) {
            // User clicked on row, load/reset station
            radioSetter.set(radioStation: DataManager.stations[indexPath.row])
            newStation = true
        } else {
            // User clicked on Now Playing button
            newStation = false
        }
        
        radioSetter.radioPlayerViewController = radioPlayerVC
        radioPlayerVC.loadRadio(station: radioSetter.radioPlayer?.station, track: radioSetter.radioPlayer?.track, isNew: newStation)
    }
    // End of Class
}



//*******************************************************************************************************************************************
//MARK: extension to load image from URL
//*******************************************************************************************************************************************

extension UIImageView {
    func downloadedFrom(link:String, name: String) {
        self.image = #imageLiteral(resourceName: "stationImage")
        //check empty url, if url empty return else load img and save
        if link == "" {
            return
        }
        guard let url = URL(string: link) else { return }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) -> Void in
            guard let data = data , error == nil, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { () -> Void in
                self.image = image
                //save image in device when image load from URL
                do {
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsURL.appendingPathComponent(name)
                    if let pngImageData = UIImagePNGRepresentation(image) {
                        try pngImageData.write(to: fileURL, options: .atomic)
                        //print("image save")
                    }
                } catch {
                    //print("Some error saving image")
                }
                //end save image
            }
        }).resume()
    }
    
    func downloadedFrom(link:String) {
        self.image = #imageLiteral(resourceName: "stationImage")
        guard let url = URL(string: link) else { return }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) -> Void in
            guard let data = data , error == nil, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { () -> Void in
                self.image = image
            }
        }).resume()
    }
}

//*******************************************************************************************************************************************
//MARK: extension to search bar
//*******************************************************************************************************************************************

extension AllStationViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            DataManager.stations = DataManager.stations.filter{$0.name.lowercased().contains(searchBar.text!.lowercased())}
            self.tableView?.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            if searchBar.text?.count == 0
            {
                DataManager.load()
                self.tableView?.reloadData()
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            }
        }
    }
}
extension AllStationViewController{
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "RadioPlayer", sender: indexPath)
    }
    
    
    
}







