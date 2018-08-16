//
//  ViewController.swift
//  RadioStation
//
//  Created by student on 8/14/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let nib = UINib(nibName: "CollectionViewCellXib", bundle: nil)
//        self.collectionView.register(nib, forCellWithReuseIdentifier: "collectionViewCell")
        
        //DataManager.load()
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(lpgr)
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.ended {
            return
        }
        
        let point = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        
        if let index = indexPath {
            
            let alertController = UIAlertController(title: "Station", message:DataManager.stations[index[1]].name, preferredStyle: .alert)
            
            let image = UIImage(named: "favorites")
            let imageView = UIImageView()
            imageView.image = image
            imageView.frame =  CGRect(x: 35, y: 89, width: 24, height: 24)
            alertController.view.addSubview(imageView)
            let addAction = UIAlertAction(title: "Add to Favourites", style: UIAlertActionStyle.default)
            { (action) in
                DataManager.stations[index[1]].favorites = true
                DataManager.loadFavorites()
                NotificationCenter.default.post(name: .reload, object: nil)
            }
            
            let image2 = UIImage(named: "delete")
            let imageView2 = UIImageView()
            imageView2.image = image2
            imageView2.frame =  CGRect(x: 67, y: 134, width: 24, height: 24)
            alertController.view.addSubview(imageView2)
            let removeAction = UIAlertAction(title: "Remove", style: UIAlertActionStyle.default)
            { (action) in
                //DataManager.stations.remove(at: index[1])
                self.collectionView?.reloadData()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            
            alertController.addAction(addAction)
            alertController.addAction(removeAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            print("Could not find index path")
        }
    }
    
    @IBAction func SetNewVC(_ sender: Any) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "TableVC") as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }

}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataManager.stations.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        let station = DataManager.stations[indexPath.row]
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
            DataManager.stations = DataManager.stations.filter{$0.name.lowercased().contains(searchBar.text!.lowercased())}
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

