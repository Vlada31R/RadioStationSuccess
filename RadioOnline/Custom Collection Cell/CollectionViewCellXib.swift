//
//  CollectionViewCellXib.swift
//  RadioStation
//
//  Created by student on 8/15/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class CollectionViewCellXib: UIView {
    @IBOutlet var cell: UIView!
    @IBOutlet weak var stationImage: UIImageView!
    @IBOutlet weak var stationName: UILabel!
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        
    }
    
    private func commonInit()
    {
        Bundle.main.loadNibNamed("CollectionViewCellXib", owner: self, options: nil)
        addSubview(cell)
        cell.frame = self.bounds
        cell.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
