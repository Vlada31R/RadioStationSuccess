//
//  CollectionViewCell.swift
//  RadioStation
//
//  Created by student on 8/14/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import ChameleonFramework

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cell: CollectionViewCellXib!
    
    func configureStationCell(station: RadioStation, view: UIView) {
        
        // Configure the cell...
        cell.stationName.text = station.name
        cell.stationImage.downloadedFrom(link: station.imageURL)
        cell.stationName.textColor = ContrastColorOf(view.backgroundColor!, returnFlat: true)
        cell.backgroundColor = view.backgroundColor
        for subview in cell.subviews {
            subview.backgroundColor = view.backgroundColor
        }
    }
}
