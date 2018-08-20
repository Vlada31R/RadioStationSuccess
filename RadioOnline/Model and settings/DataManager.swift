//
//  DataManager.swift
//  RadioStation
//
//  Created by student on 8/14/18.
//  Copyright © 2018 student. All rights reserved.
//

import Foundation
import UIKit

struct DataManager {    
    
    static func loadDataFromURL(url: URL, completion: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.allowsCellularAccess = true
        sessionConfig.timeoutIntervalForRequest = 15
        sessionConfig.timeoutIntervalForResource = 30
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        let session = URLSession(configuration: sessionConfig)
        
        // Use URLSession to get data from an NSURL
        let loadDataTask = session.dataTask(with: url) { data, response, error in
            
            guard error == nil else {
                completion(nil, error!)
                if kDebugLog { print("API ERROR: \(error!)") }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                completion(nil, nil)
                if kDebugLog { print("API: HTTP status code has unexpected value") }
                return
            }
            
            guard let data = data else {
                completion(nil, nil)
                if kDebugLog { print("API: No data received") }
                return
            }
            
            // Success, return data
            completion(data, nil)
        }
        
        loadDataTask.resume()
    }
    
    
    
    static func save(){
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("RadioStation.plist")
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(stations)
            try data.write(to: dataFilePath!)
        } catch {
            print("some write error")
        }
        
    }
    
    
    
    static func load()  {
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("RadioStation.plist")
        var arrayLoad = [RadioStation]()
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                arrayLoad = try decoder.decode([RadioStation].self, from: data)
            } catch {
                print("Error decoding data")
            }
            
        }
        if arrayLoad.isEmpty {
            firstSave()
            load()
        } else {
            stations = arrayLoad
        }
        //stations = arrayLoad
    }
    
    static func firstSave(){
        var arrayLoad = [RadioStation]()
        var radiostation = RadioStation(name: "Absolute Country Hits", streamURL: "http://strm112.1.fm/acountry_mobile_mp3", imageURL: "https://cdn-radiotime-logos.tunein.com/s98671q.png", desc: "The Music Starts Here", longDesc: "", favorites: false, new: false)
  
        arrayLoad.append(radiostation)
        
        radiostation = RadioStation(name: "Newport Folk Radio", streamURL: "http://rfcmedia.streamguys1.com/Newport.mp3", imageURL: "https://cdn-profiles.tunein.com/s249504/images/logoq.jpg", desc: "Are you ready to Folk?", longDesc: "", favorites: false, new: false)
        arrayLoad.append(radiostation)
        
        radiostation = RadioStation(name: "The Alt Vault", streamURL: "http://jupiter.prostreaming.net/altmixxlow", imageURL: "https://cdn-radiotime-logos.tunein.com/s187927q.png", desc: "Your Lifestyle... Your Music!", longDesc: "", favorites: false, new: false)
        arrayLoad.append(radiostation)

        radiostation = RadioStation(name: "Classic Rock", streamURL: "http://rfcmedia.streamguys1.com/classicrock.mp3", imageURL: "https://cdn-images.audioaddict.com/e/8/b/6/f/5/e8b6f5258a60a9a11495ecbc1d1bc881.png", desc: "Classic Rock Hits", longDesc: "", favorites: false, new: false)
        arrayLoad.append(radiostation)
        
        radiostation = RadioStation(name: "DFM Club", streamURL: "http://icecast.radiodfm.cdnvideo.ru/st01.mp3", imageURL: "http://station.ru/upload/contents/304/dfm_club.jpg", desc: "Sorry guy its for me)", longDesc: "", favorites: false, new: false)
        arrayLoad.append(radiostation)
        
        stations = arrayLoad
        save()

    }
    

    static func loadFavorites() {
        countFavorites = 0
        stationsFavorites.removeAll()
        for i in 0...stations.count-1 {
            if stations[i].favorites == true {
                if stations[i].new == true {
                    stationsFavorites.insert(stations[i], at: 0) 
                    countFavorites = countFavorites + 1
                } else {
                    stationsFavorites.append(stations[i])
                }
            }
         }
        save()
    }
    
    static func reloadFavorites(index: Int){
        for i in 0...stations.count-1 {
            if stations[i].name == stationsFavorites[index].name && stations[i].streamURL == stationsFavorites[index].streamURL {
                stations[i].favorites = false
                if stations[i].new == true {
                    stations[i].new = false
                    countFavorites = countFavorites - 1
                }
                stationsFavorites.remove(at: index)
                return
            }
        }
        save()
    }
    

    static func changeColor(view : UIView)
    {
        let userDefaults = UserDefaults.standard
        let redColor : Float
        let greenColor : Float
        let blueColor : Float
        if let redInfo = userDefaults.value(forKey: "redInfo"), let greenInfo = userDefaults.value(forKey: "greenInfo"), let blueInfo = userDefaults.value(forKey: "blueInfo")
        {
             redColor = redInfo as! Float
             greenColor = greenInfo as! Float
             blueColor = blueInfo as! Float
        }
        else
        {
             redColor = 1
             greenColor = 1
             blueColor = 1
        }
        view.backgroundColor = UIColor(red: CGFloat(redColor), green: CGFloat(greenColor), blue: CGFloat(blueColor), alpha: 1.0)
        for subview in view.subviews {
            subview.backgroundColor = view.backgroundColor
        }
    }

    static func reloadFavoritesNEW(index: Int){
        for i in 0...stations.count-1 {
            if stations[i].name == stationsFavorites[index].name && stations[i].streamURL == stationsFavorites[index].streamURL{
                if  stationsFavorites[index].new == true {
                    stations[i].new = false
                    countFavorites = countFavorites - 1
                    stationsFavorites[index].new = false
                    return
                } else {
                    return
                }
                
            }
        }
        
        //loadFavorites()
        save()

    }
    
    static func updateBandge(TabItems: NSArray?){
        if let tabItems = TabItems
        {
            //print(DataManager.countFavorites)
            let tabItem = tabItems[1] as! UITabBarItem
            if DataManager.countFavorites == 0 {
                tabItem.badgeValue = nil
            } else {
                tabItem.badgeValue = String(DataManager.countFavorites)
            }
        }
    }
    
    static func addNewRadioStation(name: String, desc: String, urlStream: String, urlImage: String){
        var newStation = RadioStation(name: name, streamURL: urlStream, imageURL: urlImage, desc: desc, longDesc: "", favorites: false, new: false)
        stations.append(newStation)
    }
    
    static func readImg(name: String) -> UIImage? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent(name).path
        if FileManager.default.fileExists(atPath: filePath) {
            return UIImage(contentsOfFile: filePath)
        }
        return nil
    }
    
    static var stations = [RadioStation]()
    static var countFavorites = 0
    static var stationsFavorites = [RadioStation]()
}













