//
//  ViewController.swift
//  RadioStation
//
//  Created by student on 8/14/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import ProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override var prefersStatusBarHidden: Bool {return DataManager.flag}

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: .reload, object: nil)

        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(lpgr)

        DataManager.changeColor(view: self.view)

        DataManager.updateBandge(TabItems: self.tabBarController?.tabBar.items as NSArray?)
    }

    @objc func reload(notification: NSNotification) {
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

            let alertController = UIAlertController(title: "Station", message: DataManager.stations[index[1]].name, preferredStyle: .alert)

            var title = ""
            let imageView = UIImageView()
            if DataManager.stations[index[1]].favorites == true {
                title = "Remove from favorites"
                let image = UIImage(named: "delete")
                imageView.image = image
                imageView.frame =  CGRect(x: 20, y: 89, width: 24, height: 24)

            } else {
                title = "Add to Favorites"
                let image = UIImage(named: "favorites")
                imageView.image = image
                imageView.frame =  CGRect(x: 35, y: 89, width: 24, height: 24)
            }
            alertController.view.addSubview(imageView)

            let addAction = UIAlertAction(title: title, style: UIAlertActionStyle.default) { (_) in
                if DataManager.stations[index[1]].favorites == true {
                    DataManager.stations[index[1]].favorites = false
                    DataManager.stations[index[1]].new = false
                    ProgressHUD.show()
                    ProgressHUD.showError("Radio station removed from favorites!")
                } else {
                    DataManager.stations[index[1]].favorites = true
                    DataManager.stations[index[1]].new = true
                    ProgressHUD.show()
                    ProgressHUD.showSuccess("Radio station add to favorites!")
                }

                DataManager.loadFavorites()
                NotificationCenter.default.post(name: .reloadFavourites, object: nil)
                DataManager.updateBandge(TabItems: self.tabBarController?.tabBar.items as NSArray?)
            }

            let image2 = UIImage(named: "delete")
            let imageView2 = UIImageView()
            imageView2.image = image2
            imageView2.frame =  CGRect(x: 67, y: 134, width: 24, height: 24)
            alertController.view.addSubview(imageView2)
            let removeAction = UIAlertAction(title: "Remove", style: UIAlertActionStyle.default) { (_) in
                //DataManager.stations.remove(at: index[1])
                //self.collectionView?.reloadData()
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

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            DataManager.flag = true
            UIView.animate(withDuration: 0.25) {
                self.setNeedsStatusBarAppearanceUpdate()
            }

        } else if scrollView.contentOffset.y < -100 {
            DataManager.flag = false
            UIView.animate(withDuration: 0.25) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    @IBAction func SetNewVC(_ sender: Any) {
        DataManager.load()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "TableVC") as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }

}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        DataManager.preparePlayerCV(radioStation: DataManager.stations[indexPath.row], tabBarController: self.tabBarController!)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataManager.stations.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! CollectionViewCell
        let station = DataManager.stations[indexPath.row]
        cell.configureStationCell(station: station, view: self.view)

        return cell
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if (kind == UICollectionElementKindSectionHeader) {
            let headerView: UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "CollectionViewHeader", for: indexPath)

            return headerView
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2-5, height: 145)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            DataManager.load()
            self.collectionView?.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            searchBar.becomeFirstResponder()
            DataManager.load()
            DataManager.stations = DataManager.stations.filter {$0.name.lowercased().contains(searchBar.text!.lowercased())}
            self.collectionView?.reloadData()

        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DataManager.load()
        self.collectionView?.reloadData()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
}
