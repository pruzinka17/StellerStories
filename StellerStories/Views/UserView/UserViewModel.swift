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
    
    enum State {
        
        case loading
        case populated
        case failure
    }
}
