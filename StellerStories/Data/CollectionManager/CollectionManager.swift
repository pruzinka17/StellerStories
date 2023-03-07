//
//  SavedStoriesManager.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 07.03.2023.
//

import Foundation

final class Collection: Codable {
        
    let id: String
    let name: String
    let userId: String
    
    var storyIds: [String]
    
    init(
        id: String,
        name: String,
        userId: String
    ) {
        
        self.id = id
        self.name = name
        self.userId = userId
        
        self.storyIds = []
    }
}

final class CollectionsManager {
    
    private let userDefaults: UserDefaults
    
    init() {
        
        self.userDefaults = .standard
    }
}

// MARK: - Collections

extension CollectionsManager {
    
    func provideCollections(
        for userId: String
    ) -> [Collection] {
        
        let key = userId
        let collections = userDefaults.array(
            forKey: key
        ) as? [Collection]
        
        return collections ?? []
    }
    
    func provideCollection(
        for id: String,
        and userId: String
    ) -> Collection? {
        
        let collections =  provideCollections(for: userId)
        
        return collections.first(where: { $0.id == id })
    }
    
    func createCollection(for userId: String, name: String) -> Bool {
        
        var collections = provideCollections(for: userId)
        
        guard !collections.contains(where: { $0.name == name }) else {
            
            return false
        }
        
        let newCollection = Collection(
            id: UUID().uuidString,
            name: name,
            userId: userId
        )
        
        collections.append(newCollection)
        
        userDefaults.set(collections, forKey: userId)
        
        return true
    }
    
    func removeCollection(for id: String, and userId: String) {
        
        var collections = provideCollections(for: userId)
        collections.removeAll { $0.id == id }

        userDefaults.set(collections, forKey: userId)
    }
}

// MARK: - Stories

extension CollectionsManager {
    
    func addStoryToCollections(
        to collectionIds: [String],
        userId: String,
        storyId: String
    ) {
        
        let collections = provideCollections(for: userId)
        
        for id in collectionIds {
        
            guard let collection = collections.first(where: { $0.id == id } ) else {
                continue
            }
            
            guard !collection.storyIds.contains(storyId) else {
                continue
            }
            
            collection.storyIds.append(storyId)
        }
        
        userDefaults.set(collections, forKey: userId)
    }
    
    func removeStoryFromCollections(
        from collectionIds: [String],
        userId: String,
        storyId: String
    ) {
        
        let collections = provideCollections(for: userId)
        
        for id in collectionIds {
            
            guard let collection = collections.first(where: { $0.id == id } ) else {
                continue
            }
            
            collection.storyIds.removeAll(where: { $0 == storyId } )
        }
        
        userDefaults.set(collections, forKey: userId)
    }
    
    func isStoryInAnyCollection(
        userId: String,
        storyId: String
    ) -> Bool {
        
        let collections = provideCollections(for: userId)
        
        for collection in collections {
            
            if collection.storyIds.contains(storyId) {
                return true
            }
        }
        
        return false
    }
    
    func collectionsWithStorySaved(
        userId: String,
        storyId: String
    ) -> [String] {
        
        var collectionsWithStory: [String] = []
        
        let collections = provideCollections(for: userId)
        
        for collection in collections {
            
            if collection.storyIds.contains(storyId) {
                
                collectionsWithStory.append(collection.id)
            }
        }
        
        return collectionsWithStory
    }
}
