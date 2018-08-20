//
//  PlayingBar.swift
//  RadioOnline
//
//  Created by student on 8/20/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit

class PlayingBar: UIView {

    @IBOutlet weak var contentView: UIView!
    
    //MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
    Bundle.main.loadNibNamed("PlayingBar", owner: self, options: nil)
    self.addSubview(contentView)
    contentView.frame = self.bounds
    contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    }
    
    //MARK: - Button Action
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        print("12")
    }
}
