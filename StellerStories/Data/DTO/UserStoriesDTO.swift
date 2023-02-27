//
//  UserStoriesDTO.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 16.02.2023.
//

import Foundation

struct UserStoriesDTO: Codable {
    
    let stories: [StoryDTO]
    
    enum CodingKeys: String, CodingKey {
        
        case stories = "data"
    }
}
