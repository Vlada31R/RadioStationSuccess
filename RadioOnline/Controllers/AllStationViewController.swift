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
    
struct My {
    static var cellSnapShot: UIView? = nil
}
    
struct Path {
    static var initialIndexPath: IndexPath? = nil
}
    
class AllStationViewController:  UIViewController,  UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var search: UISearchBar!
    
    var radioSetter = RadioSetter()
    var flag = false
    override var prefersStatusBarHidden: Bool {return flag}
    
    
    //*****************************************************************
    // MARK: - viewDidLoad Method
    //*****************************************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(gestureRecognizer:)))
        self.tableView.addGestureRecognizer(longpress)
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
    
    func clearSearchBar(){
        clearSearchBar()
    }
    
    //*****************************************************************
    // MARK: - Method fro drag and drop cell in table view
    //*****************************************************************
    
    @objc func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        
        let longpress = gestureRecognizer as! UILongPressGestureRecognizer
        let state = longpress.state
        let locationInView = longpress.location(in: self.tableView)
        var indexPath = self.tableView.indexPathForRow(at: locationInView)
        
        switch state {
        case .began:
            if indexPath != nil {
                Path.initialIndexPath = indexPath
                let cell = self.tableView.cellForRow(at: indexPath!) as! CustomCell
                My.cellSnapShot = snapshopOfCell(inputView: cell)
                var center = cell.center
                My.cellSnapShot?.center = center
                My.cellSnapShot?.alpha = 0.0
                self.tableView.addSubview(My.cellSnapShot!)
                
                UIView.animate(withDuration: 0.25, animations: {
                    center.y = locationInView.y
                    My.cellSnapShot?.center = center
                    My.cellSnapShot?.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    My.cellSnapShot?.alpha = 0.98
                    cell.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        cell.isHidden = true
                    }
                })
            }
            
        case .changed:
            var center = My.cellSnapShot!.center
            center.y = locationInView.y
            My.cellSnapShot!.center = center
            if ((indexPath != nil) && (indexPath != Path.initialIndexPath)) {
                DataManager.swap(old: indexPath!.row, new: Path.initialIndexPath!.row)
                tableView.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                Path.initialIndexPath = indexPath
                }
            
        default:
            let cell = self.tableView.cellForRow(at: Path.initialIndexPath!) as! CustomCell
            cell.isHidden = false
            cell.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: {
                My.cellSnapShot?.center = cell.center
                My.cellSnapShot?.transform = .identity
                My.cellSnapShot?.alpha = 0.0
                cell.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    Path.initialIndexPath = nil
                    My.cellSnapShot?.removeFromSuperview()
                    My.cellSnapShot = nil
                }
            })
        }
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    //*******************************************************************************************************************************************
    //MARK: tableView method
    //*******************************************************************************************************************************************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(DataManager.stations.count)
        
        return (DataManager.stations.count)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if tableView.indexPathsForVisibleRows?[0] == nil {return}
        let index = tableView.indexPathsForVisibleRows![0]
        //if  index[1] > 0 {
        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y > 0 {
            flag = true
            UIView.animate(withDuration: 0.25) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
            
        } else if scrollView.contentOffset.y < -100 {
            flag = false
            UIView.animate(withDuration: 0.25) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
        
        print(index)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        cell.backgroundColor = self.view.backgroundColor
        cell.nameLabel.text = DataManager.stations[indexPath.row].name
        cell.nameLabel.textColor = ContrastColorOf(tableView.backgroundColor!, returnFlat: true)
        cell.descriptionLabel.text = DataManager.stations[indexPath.row].desc
        cell.descriptionLabel.textColor = ContrastColorOf(tableView.backgroundColor!, returnFlat: true)
        //check image in device and load from device or internet
        
        if DataManager.stations[indexPath.row].imageURL.contains("user")
        {
            let fileManager = FileManager.default
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentDirectory = URL(fileURLWithPath: path)
            let destinationPath = documentDirectory.appendingPathComponent("\(DataManager.stations[indexPath.row].name).jpg")
            if fileManager.fileExists(atPath: destinationPath.path){
                cell.imageRadioStation.image = UIImage(contentsOfFile: destinationPath.path)
            }else{
                print("No Image")
                cell.imageRadioStation.image = #imageLiteral(resourceName: "stationImage")
            }
        }
        else
        {
            let img = DataManager.readImg(name: "\(DataManager.stations[indexPath.row].name).png")
            if img == nil || img == #imageLiteral(resourceName: "stationImage") {
                cell.imageRadioStation.downloadedFrom(link: DataManager.stations[indexPath.row].imageURL, name: "\(DataManager.stations[indexPath.row].name).png")
            } else {
                cell.imageRadioStation.image = img
                //print("image load from device")
            }
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
        
        if DataManager.stations[indexPath.row].favorites == false{
            share.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "favoritesForIOS9"))
        } else {
            share.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "delete_favoritesIOS9"))
        }

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
        searchBar.endEditing(true)
//        if(!(searchBar.text?.isEmpty)!){
//            DataManager.stations = DataManager.stations.filter{$0.name.lowercased().contains(searchBar.text!.lowercased())}
//            self.tableView?.reloadData()
//        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(!(searchBar.text?.isEmpty)!){
            DataManager.load()
            DataManager.stations = DataManager.stations.filter{$0.name.lowercased().contains(searchBar.text!.lowercased())}
            self.tableView?.reloadData()
        }
        
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







