//
//  CollectionFavoritesViewController.swift
//  RadioOnline
//
//  Created by student on 8/15/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class CollectionFavoritesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cell: CollectionViewCellXib!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: .reload, object: nil)
        //DataManager.load()
        collectionView.reloadData()
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(lpgr)
    }
    
    @objc func reload(notification: NSNotification){
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
}
extension CollectionFavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataManager.stationsFavorites.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        let station = DataManager.stationsFavorites[indexPath.row]
        cell.configureStationCell(station: station)
        return cell
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
        if(searchText.isEmpty){
            if searchBar.text?.count == 0
            {
                DataManager.load()
                self.collectionView?.reloadData()
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            }
        }
    }
}
