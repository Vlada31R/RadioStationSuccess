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
//    static func loadStationsFromJSON() -> [RadioStation] {
//        var stations = [RadioStation]()
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        // Get the Radio Stations
//        DataManager.getStationDataWithSuccess() { (data) in
//            defer {
//                DispatchQueue.main.async { UIApplication.shared.isNetworkActivityIndicatorVisible = false }
//            }
//            if kDebugLog { print("Stations JSON Found") }
//            guard let data = data,
//                let jsonDictionary = try? JSONDecoder().decode([String: [RadioStation]].self, from: data),
//                let stationsArray = jsonDictionary["station"]
//
//                else {
//                    if kDebugLog { print("JSON Station Loading Error") }
//                    return
//            }
//             stations = stationsArray
//        }
//        print(stations)
//        return stations
//    }
    
    static func getStationDataWithSuccess(success: @escaping ((_ metaData: Data?) -> Void)) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            if useLocalStations {
                getDataFromFileWithSuccess() { data in
                    success(data)
                }
            } else {
                guard let stationDataURL = URL(string: stationDataURL) else {
                    if kDebugLog { print("stationDataURL not a valid URL") }
                    success(nil)
                    return
                }
                
                loadDataFromURL(url: stationDataURL) { data, error in
                    success(data)
                }
            }
        }
    }
    
    
    static func getDataFromFileWithSuccess(success: (_ data: Data?) -> Void) {
        guard let filePathURL = Bundle.main.url(forResource: "stations", withExtension: "json") else {
            if kDebugLog { print("The local JSON file could not be found") }
            success(nil)
            return
        }
        
        do {
            let data = try Data(contentsOf: filePathURL, options: .uncached)
            success(data)
        } catch {
            fatalError()
        }
    }
    
    
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
        
        radiostation = RadioStation(name: "Radio 1190", streamURL: "http://radio1190.colorado.edu:8000/high.mp3", imageURL: "https://mytuner.global.ssl.fastly.net/media/tvos_radios/yyz3srxjbd6u.png", desc: "KVCU - Boulder, CO", longDesc: "", favorites: false, new: false)
        arrayLoad.append(radiostation)
        
        stations = arrayLoad
        save()

    }
    

    static func loadFavorites() {
        stationsFavorites.removeAll()
        for i in 0...stations.count-1 {
            if stations[i].favorites == true {
                stationsFavorites.append(stations[i])
            }
         }
        save()
    }
    
    static func reloadFavorites(index: Int){
        for i in 0...stations.count-1 {
            if stations[i].name == stationsFavorites[index].name && stations[i].streamURL == stationsFavorites[index].streamURL {
                stations[i].favorites = false
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
    
    static var stations = [RadioStation]()
    static var stationsFavorites = [RadioStation]()
}













