//
//  CollectionModel.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 07.03.2023.
//

import Foundation

final class Collection: Codable {
        
    let id: String
    let name: String
    let userId: String
    
    var storyIds: [String]
    
    init(
        id: String,
        name: String,
        userId: String
    ) {
        
        self.id = id
        self.name = name
        self.userId = userId
        
        self.storyIds = []
    }
}
