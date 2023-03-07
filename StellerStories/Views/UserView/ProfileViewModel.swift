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
    var collections: CollectionState
    
    struct Story {
        
        let id: String
        
        let coverSource: URL
        let coverBackground: String
        
        let commentCount: Int
        let likeCount: Int
        
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
    
    enum CollectionState {
        
        case populated([Collection])
        case empty
        
        struct Collection {
            
            let id: String
            let name: String
            let numberOfSaves: String
        }
    }
    
    enum State<T> {
        
        case loading
        case populated(T)
        case failure
    }
}
