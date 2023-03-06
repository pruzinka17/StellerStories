//
//  UserListViewModel.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 02.03.2023.
//

import Foundation

struct UserListViewModel {
    
    var users: [User]
    
    struct User: Identifiable {
        
        let id: String
        
        let displayName: String
        let userName: String
        
        let avatarURL: URL
        let avatarBackground: String
    }
    
//    enum State<T> {
//
//        case loading
//        case populated(T)
//        case failure
//    }
}
