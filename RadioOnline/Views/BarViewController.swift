//
//  BarViewController.swift
//  RadioOnline
//
//  Created by student on 8/22/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
protocol BarViewControllerDelegate {
    func didTapped(sender: UITapGestureRecognizer)
}
class BarViewController: UIViewController {

    
    var delegate: BarViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapG = UITapGestureRecognizer(target: self, action: #selector(didTapped))
        self.view.addGestureRecognizer(tapG)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func didTapped( sender: UITapGestureRecognizer){
        self.delegate?.didTapped(sender: sender)
    }

    override func loadView() {
        Bundle.main.loadNibNamed("BarViewController", owner: self, options: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
