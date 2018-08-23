//
//  CollectionFavoritesViewController.swift
//  RadioOnline
//
//  Created by student on 8/15/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import ChameleonFramework
import ProgressHUD

class CollectionFavoritesViewController: UIViewController {

    var radioSetter = RadioSetter()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        radioSetter.setupRadio()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: .reload, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadFavourites(notification:)), name: .reloadFavourites, object: nil)
        collectionView.reloadData()
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(lpgr)
        
        DataManager.changeColor(view: self.view)
    }
    
    @objc func reload(notification: NSNotification){
        DataManager.changeColor(view: self.view)
        collectionView.reloadData()
    }
    @objc func reloadFavourites(notification: NSNotification){
        DataManager.changeColor(view: self.view)
        collectionView.reloadData()
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.ended {
            return
        }
        
        let point = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        
        if let index = indexPath {
            
            let alertController = UIAlertController(title: "Station", message:DataManager.stationsFavorites[index[1]].name, preferredStyle: .alert)
            
            let image = UIImage(named: "delete")
            let imageView = UIImageView()
            imageView.image = image
            imageView.frame =  CGRect(x: 138, y: 89, width: 24, height: 24)
            alertController.view.addSubview(imageView)
            let removeAction = UIAlertAction(title: "Remove", style: UIAlertActionStyle.default)
            { (action) in
                DataManager.stationsFavorites[index[1]].favorites = false
                ProgressHUD.show()
                ProgressHUD.showError("Radio station removed from favorites!")
                DataManager.reloadFavorites(index: index[1])
                self.collectionView.reloadData()
            }
            
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            
            alertController.addAction(removeAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            print("Could not find index path")
        }
    }
    
    @IBAction func SetNewVc(_ sender: Any) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "AllVC") as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "RadioPlayer", let radioPlayerVC = segue.destination as? RadioPlayerViewController else { return }
        
        
        let newStation: Bool
        
        if let indexPath = (sender as? IndexPath) {
            radioSetter.set(radioStation: DataManager.stationsFavorites[indexPath.row])
            newStation = true
        } else {
            newStation = false
        }
        
        radioSetter.radioPlayerViewController = radioPlayerVC
        radioPlayerVC.loadRadio(station: radioSetter.radioPlayer?.station, track: radioSetter.radioPlayer?.track, isNew: newStation)
    }
}

extension Notification.Name {
   // static let reload = Notification.Name("reload")
    static let reloadFavourites = Notification.Name("reload Favourites")
}

extension CollectionFavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2-5, height: 145)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        DataManager.updateBandge(TabItems: self.tabBarController?.tabBar.items as NSArray?)
        return DataManager.stationsFavorites.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        let station = DataManager.stationsFavorites[indexPath.row]
        cell.configureStationCell(station: station, view: self.view, fav: true)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if DataManager.stationsFavorites[indexPath.row].new == true {
            DataManager.reloadFavoritesNEW(index: indexPath.row)
            DataManager.updateBandge(TabItems: self.tabBarController?.tabBar.items as NSArray?)
            collectionView.reloadItems(at: [indexPath])
        }
        collectionView.deselectItem(at: indexPath, animated: true)
        performSegue(withIdentifier: "RadioPlayer", sender: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionElementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)
            
            return headerView
        }
        return UICollectionReusableView()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(!(searchBar.text?.isEmpty)!){
            DataManager.stationsFavorites = DataManager.stationsFavorites.filter{$0.name.lowercased().contains(searchBar.text!.lowercased())}
            self.collectionView?.reloadData()
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0
        {
            DataManager.loadFavorites()
            self.collectionView?.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        else
        {
            searchBar.becomeFirstResponder()
            DataManager.loadFavorites()
            DataManager.stationsFavorites = DataManager.stationsFavorites.filter{$0.name.lowercased().contains(searchBar.text!.lowercased())}
            self.collectionView?.reloadData()
            
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DataManager.loadFavorites()
        self.collectionView?.reloadData()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
}
