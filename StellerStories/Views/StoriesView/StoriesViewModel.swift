//
//  StoriesViewModel.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 28.02.2023.
//

import Foundation

struct StoriesViewModel {
    
    var presentedStoryId: String
    
    var viewBackgroundColor: String
    
    var stories: [Story]
    
    var collections: CollectionState
    
    enum CollectionState {
        
        case populated([Collection])
        case empty
        
        struct Collection {
            
            let id: String
            let name: String
            let numberOfSaves: String
        }
    }
}
