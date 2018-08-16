//
//  RadioStation.swift
//  RadioStation
//
//  Created by student on 8/14/18.
//  Copyright © 2018 student. All rights reserved.
//

import Foundation

struct RadioStation: Codable {
    
    var name: String
    var streamURL: String
    var imageURL: String
    var desc: String
    var favorites : Bool
    var new : Bool
    
    init(name: String, streamURL: String, imageURL: String, desc: String, longDesc: String = "", favorites: Bool, new: Bool) {
        self.name = name
        self.streamURL = streamURL
        self.imageURL = imageURL
        self.desc = desc
        self.favorites = favorites
        self.new = new
    }
}
