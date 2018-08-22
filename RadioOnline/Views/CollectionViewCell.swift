//
//  CollectionViewCell.swift
//  RadioStation
//
//  Created by student on 8/14/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import ChameleonFramework
import Photos


class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cell: CollectionViewCellXib!
    
    func configureStationCell(station: RadioStation, view: UIView,fav : Bool = false) {

        cell.stationName.text = station.name
        print(station.imageURL)
        if station.imageURL.contains("user")
        {
            let fileManager = FileManager.default
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentDirectory = URL(fileURLWithPath: path)
            let destinationPath = documentDirectory.appendingPathComponent("\(station.name).jpg")
            if fileManager.fileExists(atPath: destinationPath.path){
                cell.stationImage.image = UIImage(contentsOfFile: destinationPath.path)
            }else{
                print("No Image")
                cell.stationImage.image = #imageLiteral(resourceName: "stationImage")
            }
        }
        else
        {
            let img = DataManager.readImg(name: "\(station.name).png")
            if img == nil || img == #imageLiteral(resourceName: "stationImage") {
                cell.stationImage.downloadedFrom(link: station.imageURL, name: "\(station.name).png")
            } else {
                cell.stationImage.image = img
            }
        }
        
        cell.stationName.textColor = ContrastColorOf(view.backgroundColor!, returnFlat: true)
        
        cell.backgroundColor = view.backgroundColor
        for subview in cell.subviews {
            subview.backgroundColor = view.backgroundColor
        }
        
        cell.newLabel.isHidden = true
        if fav == true
        {
            if station.new == true {
                //let image = cell.stationImage.image
                //cell.newLabel.frame.origin.x = (cell.stationImage.frame.width - (image?.size.width)!)/2
                cell.newLabel.layer.cornerRadius = 10
                cell.newLabel.isHidden = false
                cell.newLabel.layer.masksToBounds = true
                cell.newLabel.layer.cornerRadius = 10
            } else {
                cell.newLabel.isHidden = true
            }
        }
    }
}
