//
//  Movie.swift
//  The 10 - Adrian
//
//  Created by Adrian Navarro on 2/15/19.
//  Copyright © 2019 Adrian Navarro. All rights reserved.
//

import Foundation
import UIKit

struct Movie {
    let id: Int
    let posterPath: String
    let videoPath: String?
    let backdrop: String
    let title: String
    var releaseDate: String
    var rating: Double
    let description: String
    var trailerKey: String?
//
//    enum CodingKeys: String, CodingKey {
//
//        case posterPath = "poster_path"
//        case videoPath = "video_path"
//        case backdrop = "backdrop_path"
//        case title = "title"
//        case releaseDate = "release_date"
//        case rating = "vote_average"
//        case description = "overview"
//    }
    
    
    init(dictionary: [String:Any]) {
        
        
        if let id = dictionary["id"] as? Int {
            self.id = id
        } else {
            self.id = 0
            print("No ID")
        }
        
        if let posterPath = dictionary["poster_path"] as? String {
            self.posterPath = posterPath
        } else {
            posterPath = ""
        }
        
        if let videoPath = dictionary["video_path"] as? String{
            self.videoPath = videoPath
        } else {
            self.videoPath = ""
        }
        
        if let backdrop = dictionary["backdrop_path"] as? String{
            self.backdrop = backdrop
        } else {
            self.backdrop = ""
        }
        
        if let title = dictionary["title"] as? String{
            self.title = title
        } else {
            self.title = ""
        }
        
        if let releaseDate = dictionary["release_date"] as? String{
            self.releaseDate = releaseDate
        } else {
            self.releaseDate = ""
        }
        
        if let rating = dictionary["vote_average"] as? Double{
            self.rating = rating
        } else {
            self.rating = 0
        }
        
        if let description = dictionary["overview"] as? String{
            self.description = description
        } else {
            self.description = ""
        }
        
        trailerKey = ""
        
        
    }
    
}





