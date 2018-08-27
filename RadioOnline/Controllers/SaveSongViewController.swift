//
//  SaveSongViewController.swift
//  RadioOnline
//
//  Created by student on 8/22/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import Foundation
import ChameleonFramework

class SaveSongViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var songArray = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //firstSave()
       // save()
        load()
        let nib = UINib(nibName: "CustomCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "Cell")
    }
    
    func save(){
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Song.plist")
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(songArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("some write error")
        }
        
    }
    
    
    
    func load()  {
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Song.plist")
        var array = [Song]()
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                array = try decoder.decode([Song].self, from: data)
            } catch {
                print("Error decoding data")
            }
            for arrayIndex in array{
            songArray.append(arrayIndex)
            }
            save()
        }
        
    }
    
    func firstSave(){
        var arrayLoad = [Song]()
        var song = Song(s: "Nosa", a: "Kokos")

        arrayLoad.append(song)

        song = Song(s: "koks", a: "mu")

        arrayLoad.append(song)
         song = Song(s: "ggg", a: "my")

        arrayLoad.append(song)
         song = Song(s: "eee", a: "hello")

        arrayLoad.append(song)

        songArray = arrayLoad

        save()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        cell.backgroundColor = self.view.backgroundColor
        cell.nameLabel.text = songArray[indexPath.row].song
        cell.nameLabel.textColor = ContrastColorOf(tableView.backgroundColor!, returnFlat: true)
        cell.descriptionLabel.text = songArray[indexPath.row].artist
        cell.descriptionLabel.textColor = ContrastColorOf(tableView.backgroundColor!, returnFlat: true)
        
        //cell.imageRadioStation.image = songArray[indexPath.row].img
        
        
        return cell
        
    }

    @IBAction func backButton(_ sender: Any) {
        self.save()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeAllButton(_ sender: Any) {
    }

}

class Song: NSData{
    var song: String
    var artist: String
    var img: NSData
    
    init(s: String, a: String, i: UIImage? = nil){
        song = s
        artist = a
       // img = UIImagePNGRepresentation(i) as! NSData
       // img = i
    }
    
    required init?(coder aDecoder: NSCoder) {

    }
}
