//
//  CrewMember.swift
//  The 10 - Adrian
//
//  Created by Adrian Navarro on 2/16/19.
//  Copyright © 2019 Adrian Navarro. All rights reserved.
//

import Foundation
struct CrewMember {
let id: Int
let name: String
let headShotPath: String
let job: String
let creditID: String

init(dictionary: [String:Any]) {
    if let id = dictionary["id"] as? Int {
        self.id = id
    } else {
        self.id = 0
    }
    
    if let name = dictionary["name"] as? String {
        self.name = name
    } else {
        self.name = ""
    }
    
    if let headShotPath = dictionary["profile_path"] as? String {
        self.headShotPath = headShotPath
    } else {
        self.headShotPath = ""
    }
    
    if let job = dictionary["known_for_department"] as? String {
        self.job = job
    } else {
        self.job = ""
    }
    
    if let creditID = dictionary["credit_id"] as? String {
        self.creditID = creditID
    } else {
        self.creditID = ""
    }

    }
    
}
