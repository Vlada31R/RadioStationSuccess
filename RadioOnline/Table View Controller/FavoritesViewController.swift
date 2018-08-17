//
//  FavoritesViewController.swift
//  RadioOnline
//
//  Created by student on 8/14/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import Foundation

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

  
    @IBOutlet weak var favoritesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: .reload, object: nil)
        //DataManager.loadFavorites()
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        self.favoritesTableView.register(nib, forCellReuseIdentifier: "Cell")
        
    }

    @objc func reload(notification: NSNotification){
        favoritesTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (DataManager.stationsFavorites.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        cell.nameLabel.text = DataManager.stationsFavorites[indexPath.row].name
        cell.descriptionLabel.text = DataManager.stationsFavorites[indexPath.row].desc
        cell.imageRadioStation.downloadedFrom(link: DataManager.stationsFavorites[indexPath.row].imageURL)
        return cell
        
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

