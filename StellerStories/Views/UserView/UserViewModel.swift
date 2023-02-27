//
//  UserViewModel.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 18.02.2023.
//

import Foundation

struct UserViewModel {
    
    var userFetchFailed: Bool
    var storiesFetchFailed: Bool
    var error: Error?
    
    var presentedStoryId: String
    
    var user: User
    
    var stories: [Story]
    
    struct User {
        
        var displayName: String
        var userName: String
        
        var headerImageUrl: String
        var headerImageBackground: String
        
        var avatarImageUrl: String
        var avatarImageBackground: String
        
        var bio: String?
    }
    
    struct Story {
        
        var id: String
        
        var coverSource: String
        var coverBackground: String
        
        var title: String?
        
        var commentCount: Int
        
        var aspectRatio: String
        
        var likes: Int
    }
}
