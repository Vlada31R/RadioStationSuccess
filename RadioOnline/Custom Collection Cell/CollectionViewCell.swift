//
//  CollectionViewCell.swift
//  RadioStation
//
//  Created by student on 8/14/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cell: CollectionViewCellXib!
    
    func configureStationCell(station: RadioStation) {
        
        // Configure the cell...
        cell.stationName.text = station.name
        cell.stationImage.downloadedFrom(link: station.imageURL)
    }
}
