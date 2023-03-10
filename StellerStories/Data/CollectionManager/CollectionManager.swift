//
//  SavedStoriesManager.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 07.03.2023.
//

import Foundation

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
        
        guard
            let data = userDefaults.object(forKey: key) as? Data,
            let collections = try? JSONDecoder().decode([Collection].self, from: data)
        else {
            return []
        }
        
        return collections
    }
    
    func provideCollection(
        for id: String,
        and userId: String
    ) -> Collection? {
        
        let collections = provideCollections(for: userId)
        
        return collections.first(where: { $0.id == id })
    }
    
    func createCollection(
        for userId: String,
        name: String
    ) -> Bool {
        
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
        
        updateCollections(userId: userId, collections: collections)
        
        return true
    }
    
    func removeCollection(for id: String, and userId: String) {
        
        var collections = provideCollections(for: userId)
        collections.removeAll { $0.id == id }
        
        updateCollections(userId: userId, collections: collections)
    }
}

// MARK: - Stories

extension CollectionsManager {
    
    func addStoryToCollections(
        collectionIds: [String],
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
        
        updateCollections(userId: userId, collections: collections)
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
        
        updateCollections(userId: userId, collections: collections)
    }
    
    func isStorySaved(
        userId: String,
        storyId: String
    ) -> Bool {
        
        return !storyInCollections(
            userId: userId,
            storyId: storyId
        ).isEmpty
    }
    
    func storyInCollections(
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

// MARK: - helper methods

private extension CollectionsManager {
    
    func updateCollections(userId: String, collections: [Collection]) {
        
        guard
            let encoded = try? JSONEncoder().encode(collections)
        else {
            return
        }
    
        userDefaults.set(encoded, forKey: userId)
    }
}
