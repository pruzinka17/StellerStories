//
//  UserListViewModel.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 02.03.2023.
//

import Foundation

struct UserListViewModel {
    
    var usersState: State<[User]>
    
    struct User: Identifiable {
        
        let id: String
        
        let displayName: String
        let userName: String
        
        let avatarURL: String
        let avatarBackground: String
        
    }
    
    enum State<T> {
        
        case loading
        case populated(T)
        case failure
    }
}
