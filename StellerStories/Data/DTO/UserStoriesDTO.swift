//
//  UserStoriesDTO.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 16.02.2023.
//

import Foundation

struct UserStoriesDTO: Codable {
    
    let stories: [StoryDTO]
    let cursor: Cursor?
    
    struct Cursor: Codable {
        
        let after: String?
    }
    
    enum CodingKeys: String, CodingKey {
        
        case stories = "data"
        case cursor = "cursor"
    }
}
