import Foundation

struct RadioStation: Codable {

    var name: String
    var streamURL: String
    var imageURL: String
    var desc: String
    var favorites: Bool
    var new: Bool

    init(name: String, streamURL: String, imageURL: String, desc: String, longDesc: String = "", favorites: Bool, new: Bool) {
        self.name = name
        self.streamURL = streamURL
        self.imageURL = imageURL
        self.desc = desc
        self.favorites = favorites
        self.new = new
    }
}
extension RadioStation: Equatable {

    static func ==(lhs: RadioStation, rhs: RadioStation) -> Bool {
        return (lhs.name == rhs.name) && (lhs.streamURL == rhs.streamURL) && (lhs.imageURL == rhs.imageURL) && (lhs.desc == rhs.desc)
    }
}
