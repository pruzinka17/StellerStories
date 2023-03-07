//
//  SavedStoriesManager.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 07.03.2023.
//

import Foundation

struct StoriesCollection {
        
    let name: String
    var stories: [String]
}

final class SavedStoriesManager {
    
    private let userDefaults: UserDefaults
    
    init() {
        
        self.userDefaults = .standard
    }
}

// MARK: - Collections

extension SavedStoriesManager {
    
    func provideStoryCollections(for userId: String) -> [StoriesCollection] {
        
        var storyCollections = userDefaults.object(forKey: userId) as? [StoriesCollection]
        
        return storyCollections ?? []
    }
    
    func provideStoryCollection(for userId: String, collectionName: String) -> StoriesCollection {
        
        let storyCollections =  provideStoryCollections(for: userId)
        let collection = storyCollections.first(where: { $0.name == collectionName } )
        
        return collection ?? StoriesCollection(name: "", stories: [])
    }
    
    func addStoryCollection(for userId: String, collectionName: String) -> Bool {
        
        var storyCollections = provideStoryCollections(for: userId)
        
        if !storyCollections.contains(where: { $0.name == collectionName } ) {
            
            storyCollections.append(StoriesCollection(name: collectionName, stories: []))
            
            userDefaults.set(storyCollections, forKey: userId)
            
            return true
        }
        return false
    }
    
    func removeStoryCollection(for userId: String, collectionName: String) -> Bool {
        
        var storiesCollections = provideStoryCollections(for: userId)
        
        if storiesCollections.contains(where: { $0.name == collectionName } ) {
            
            storiesCollections.removeAll(where: { $0.name == collectionName } )
            
            userDefaults.set(storiesCollections, forKey: userId)
            
            return true
        }
        
        return false
    }
}

// MARK: - Stories

extension SavedStoriesManager {
    
    func addStoryToCollection(for userId: String, collectionName: String, storyId: String) {
        
        var collections = provideStoryCollections(for: userId)
        var collection = provideStoryCollection(for: userId, collectionName: collectionName)
        
        collection.stories.append(storyId)
        
        collections.removeAll(where: { $0.name == collectionName } )
        collections.append(collection)
        
        userDefaults.set(collections, forKey: userId)
    }
    
    func removeStoryFromCollection(for userId: String, colletionName: String, storyId: String) {
        
        var collections = provideStoryCollections(for: userId)
        var collection = provideStoryCollection(for: userId, collectionName: colletionName)
        
        collection.stories.removeAll(where: { $0 == storyId } )
        
        collections.removeAll(where: { $0.name == colletionName } )
        collections.append(collection)
        
        userDefaults.set(collections, forKey: userId)
    }
}
