//
//  AllStationViewController.swift
//  RadioOnline
//
//  Created by student on 8/15/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class AllStationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add xib cell
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
        //set bandge
        if let tabItems = self.tabBarController?.tabBar.items as NSArray?
        {
            let tabItem = tabItems[1] as! UITabBarItem
            if DataManager.countFavorites == 0 {
                tabItem.badgeValue = nil
            } else {
                tabItem.badgeValue = String(DataManager.countFavorites)
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //*******************************************************************************************************************************************
    //MARK: tableView method
    //*******************************************************************************************************************************************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (DataManager.stations.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        cell.nameLabel.text = DataManager.stations[indexPath.row].name
        cell.descriptionLabel.text = DataManager.stations[indexPath.row].desc
        cell.imageRadioStation.downloadedFrom(link: DataManager.stations[indexPath.row].imageURL)
        return cell
    }
    
    //*******************************************************************************************************************************************
    //MARK: tableView cell swipe
    //*******************************************************************************************************************************************
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let flagAction = self.contextualToggleFlagAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [flagAction])
        return swipeConfig
    }
    
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
    
    func addFavorites(_ indexPath: IndexPath) -> Bool{
        DataManager.stations[indexPath.row].favorites = true
        DataManager.stations[indexPath.row].new = true
        DataManager.loadFavorites()
        if let tabItems = self.tabBarController?.tabBar.items as NSArray?
        {
            let tabItem = tabItems[1] as! UITabBarItem
            if DataManager.countFavorites == 0 {
                tabItem.badgeValue = nil
            } else {
                tabItem.badgeValue = String(DataManager.countFavorites)
            }
        }
        NotificationCenter.default.post(name: .reload, object: nil)
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
}

//*******************************************************************************************************************************************
//MARK: extension to load image from URL
//*******************************************************************************************************************************************

extension UIImageView {
    
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








