//
//  AllStationViewController.swift
//  RadioOnline
//
//  Created by student on 8/15/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import ChameleonFramework

class AllStationViewController:  UIViewController,  UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var nowPlayingSongBar: UIView!
    
    var radioSetter = RadioSetter()
    
    //*****************************************************************
    // MARK: - viewDidLoad Method
    //*****************************************************************
    override func viewDidLoad() {
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
        return (DataManager.stations.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        cell.backgroundColor = self.view.backgroundColor
        cell.nameLabel.text = DataManager.stations[indexPath.row].name
        cell.nameLabel.textColor = ContrastColorOf(tableView.backgroundColor!, returnFlat: true)
        cell.descriptionLabel.text = DataManager.stations[indexPath.row].desc
        cell.descriptionLabel.textColor = ContrastColorOf(tableView.backgroundColor!, returnFlat: true)
        cell.imageRadioStation.downloadedFrom(link: DataManager.stations[indexPath.row].imageURL)
        return cell
    }
    
    //*******************************************************************************************************************************************
    //MARK: tableView cell swipe
    //*******************************************************************************************************************************************
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
        if DataManager.stations[indexPath.row].favorites == true {
            DataManager.stations[indexPath.row].favorites = false
            DataManager.stations[indexPath.row].new = false
            let alert = UIAlertController(title: "Radiostation removed from favorites!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            DataManager.stations[indexPath.row].favorites = true
            DataManager.stations[indexPath.row].new = true
            let alert = UIAlertController(title: "Radiostation add to favorites!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
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
        
        title = ""
        
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







