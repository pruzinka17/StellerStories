//
//  ProfileViewModel.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 18.02.2023.
//

import Foundation

struct ProfileViewModel {
    
    var state: State<User>
    var storiesState: State<[Story]>
    
    struct Story {
        
        let id: String
        
        let coverSource: URL
        let coverBackground: String
        
        let commentCount: Int
        let likes: Int // TODO: Rename
        
        let aspectRatio: AspectRatio
    }
    
    struct User {
        
        let displayName: String
        let userName: String
        
        let headerImageUrl: URL
        let headerImageBackground: String
        
        let avatarImageUrl: URL
        let avatarImageBackground: String
        
        let bio: String?
    }
    
    enum State<T> {
        
        case loading
        case populated(T)
        case failure
    }
}
