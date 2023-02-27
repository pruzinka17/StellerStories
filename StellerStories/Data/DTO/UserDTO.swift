//
//  UserDTO.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 16.02.2023.
//

import Foundation

struct UserDTO: Codable {
    
    let id: String
    
    let displayName: String
    let userName: String
    
    let headerImageUrl: String
    let headerImageBackground: String
    
    let avatarImageUrl: String
    let avatarImageBackground: String
    
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        
        case displayName = "display_name"
        case userName = "username"
        
        case headerImageUrl = "header_image_url"
        case headerImageBackground = "header_image_bg"
        
        case avatarImageUrl = "avatar_image_url"
        case avatarImageBackground = "avatar_image_bg"
        
        case bio = "bio"
    }
}
