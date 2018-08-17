//
//  FavoritesViewController.swift
//  RadioOnline
//
//  Created by student on 8/14/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import Foundation
import ChameleonFramework

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  
    @IBOutlet weak var favoritesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: .reload, object: nil)
        //DataManager.loadFavorites()
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        self.favoritesTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        DataManager.changeColor(view: self.view)
    }

    @objc func reload(notification: NSNotification){
        DataManager.changeColor(view: self.view)
        favoritesTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tabItems = self.tabBarController?.tabBar.items as NSArray?
        {
            //print(DataManager.countFavorites)
            let tabItem = tabItems[1] as! UITabBarItem
            if DataManager.countFavorites == 0 {
                tabItem.badgeValue = nil
            } else {
                tabItem.badgeValue = String(DataManager.countFavorites)
            }
        }
        return (DataManager.stationsFavorites.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        cell.backgroundColor = self.view.backgroundColor
        cell.nameLabel.text = DataManager.stationsFavorites[indexPath.row].name
        cell.nameLabel.textColor = ContrastColorOf(tableView.backgroundColor!, returnFlat: true)
        cell.descriptionLabel.text = DataManager.stationsFavorites[indexPath.row].desc
        cell.descriptionLabel.textColor = ContrastColorOf(tableView.backgroundColor!, returnFlat: true)
        cell.imageRadioStation.downloadedFrom(link: DataManager.stationsFavorites[indexPath.row].imageURL)
        if DataManager.stationsFavorites[indexPath.row].new == true {
            cell.newLabel.isHidden = false
        } else {
            cell.newLabel.isHidden = true
        }
        if let tabItems = self.tabBarController?.tabBar.items as NSArray?
        {
            //print(DataManager.countFavorites)
            let tabItem = tabItems[1] as! UITabBarItem
            if DataManager.countFavorites == 0 {
                tabItem.badgeValue = nil
            } else {
                tabItem.badgeValue = String(DataManager.countFavorites)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if DataManager.stationsFavorites[indexPath.row].new == true {
            DataManager.reloadFavoritesNEW(index: indexPath.row)
            if let tabItems = self.tabBarController?.tabBar.items as NSArray?
            {
                //print(DataManager.countFavorites)
                let tabItem = tabItems[1] as! UITabBarItem
                if DataManager.countFavorites == 0 {
                    tabItem.badgeValue = nil
                } else {
                    tabItem.badgeValue = String(DataManager.countFavorites)
                }
            }
            favoritesTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
    
    func contextualDeleteAction(forRowAtIndexPath indexPath: IndexPath)-> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (contextAction: UIContextualAction, sourceView: UIView, completionHandler: (Bool) -> Void) in
            
            if self.deleteRadiostation(indexPath) {
                completionHandler(true)
                self.favoritesTableView.reloadData()
            } else {
                completionHandler(false)
            }
            
        }
        action.image = UIImage(named: "delete")
        return action
        
    }
    
    func deleteRadiostation(_ indexPath: IndexPath) -> Bool{
        if indexPath.row <= DataManager.stationsFavorites.count {
            DataManager.stationsFavorites[indexPath.row].favorites = false
            DataManager.reloadFavorites(index: indexPath.row)
            //DataManager.save(array: stations)
            //stations = DataManager.loadFavorites()
            //stations.remove(at: indexPath.row)
            return true
        } else {
            print("error deleting radiostation")
            return false
        }
        
    }
    
    
}

extension Notification.Name {
    static let reload = Notification.Name("reload")
    
}

extension FavoritesViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            DataManager.stationsFavorites = DataManager.stationsFavorites.filter{$0.name.lowercased().contains(searchBar.text!.lowercased())}
            self.favoritesTableView?.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.isEmpty){
            if searchBar.text?.count == 0
            {
                DataManager.loadFavorites()
                self.favoritesTableView?.reloadData()
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            }
        }
    }
    
}

