//
//  UserViewModel.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 18.02.2023.
//

import Foundation

struct UserViewModel {
    
    var state: State
    var storiesState: State
    
    var user: User
    
    var stories: [Story]
    
    struct User {
        
        let displayName: String
        let userName: String
        
        let headerImageUrl: String
        let headerImageBackground: String
        
        let avatarImageUrl: String
        let avatarImageBackground: String
        
        let bio: String?
    }
    
    enum State {
        
        case loading
        case populated
        case failure
    }
}
