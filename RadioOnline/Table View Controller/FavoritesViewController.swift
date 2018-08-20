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
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView(notification:)), name: .reloadFavoritesTableView, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: .reload, object: nil)
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        self.favoritesTableView.register(nib, forCellReuseIdentifier: "Cell")
        DataManager.changeColor(view: self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //*******************************************************************************************************************************************
    //MARK: Notification method
    //*******************************************************************************************************************************************
    
    @objc func reload(notification: NSNotification){
        DataManager.changeColor(view: self.view)
        favoritesTableView.reloadData()
    }
    
    @objc func reloadTableView(notification: NSNotification){
        DataManager.changeColor(view: self.view)
        favoritesTableView.reloadData()
    }
    
    //*******************************************************************************************************************************************
    //MARK: table view method
    //*******************************************************************************************************************************************

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DataManager.updateBandge(TabItems: self.tabBarController?.tabBar.items as NSArray?)
        return (DataManager.stationsFavorites.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        cell.backgroundColor = self.view.backgroundColor
        cell.nameLabel.text = DataManager.stationsFavorites[indexPath.row].name
        cell.nameLabel.textColor = ContrastColorOf(tableView.backgroundColor!, returnFlat: true)
        cell.descriptionLabel.text = DataManager.stationsFavorites[indexPath.row].desc
        cell.descriptionLabel.textColor = ContrastColorOf(tableView.backgroundColor!, returnFlat: true)
        
        let img = DataManager.readImg(name: "\(DataManager.stationsFavorites[indexPath.row].name).png")
        if img == nil || img == #imageLiteral(resourceName: "stationImage") {
            cell.imageRadioStation.downloadedFrom(link: DataManager.stationsFavorites[indexPath.row].imageURL, name: "\(DataManager.stations[indexPath.row].name).png")
        } else {
            cell.imageRadioStation.image = img
            print("image load from device")
        }
        
        if DataManager.stationsFavorites[indexPath.row].new == true {
            cell.newLabel.isHidden = false
            cell.newLabel.layer.masksToBounds = true
            cell.newLabel.layer.cornerRadius = 10
        } else {
            cell.newLabel.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if DataManager.stationsFavorites[indexPath.row].new == true {
            DataManager.reloadFavoritesNEW(index: indexPath.row)
            DataManager.updateBandge(TabItems: self.tabBarController?.tabBar.items as NSArray?)
            favoritesTableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //*******************************************************************************************************************************************
    //MARK: func - set swipe cell table view
    //*******************************************************************************************************************************************
    @available(iOS 9.0, *)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let share = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            if indexPath.row <= DataManager.stationsFavorites.count {
                DataManager.stationsFavorites[indexPath.row].favorites = false
                DataManager.reloadFavorites(index: indexPath.row)
                self.favoritesTableView.reloadData()
            } else {
                print("error deleting radiostation")
                
            }
        }
        share.backgroundColor = .red
        share.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "delete"))
        
        return [share]
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = self.contextualDeleteAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfig
    }
    
    @available(iOS 11.0, *)
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
    
    @available(iOS 11.0, *)
    func deleteRadiostation(_ indexPath: IndexPath) -> Bool{
        if indexPath.row <= DataManager.stationsFavorites.count {
            DataManager.stationsFavorites[indexPath.row].favorites = false
            DataManager.reloadFavorites(index: indexPath.row)
            //favoritesTableView.reloadData()
            return true
        } else {
            print("error deleting radiostation")
            return false
        }
    }
}

//*******************************************************************************************************************************************
//MARK: extension notification settings
//*******************************************************************************************************************************************

extension Notification.Name {
    static let reload = Notification.Name("reload")
    static let reloadFavoritesTableView = Notification.Name("reload Table View")
}

//*******************************************************************************************************************************************
//MARK: extension to search bar
//*******************************************************************************************************************************************

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

