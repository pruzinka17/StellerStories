//
//  UserService.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 18.02.2023.
//

import Foundation

final class UserService {
    
    private let networkService: NetworkService
    
    private var userCache: [(Date, User)]
    private var storyCache: [(Date, String, [Story])]
    
    init(networkService: NetworkService) {
        
        self.networkService = networkService
        self.userCache = []
        self.storyCache = []
    }
}

extension UserService {
    
    func fetchUser(userId: String) async -> Result<User, Error> {
        
        clearUserCache()
        
        if let (_, user) = userCache.first(where: { $0.1.id == userId } ) {
            
            return .success(user)
        }
        
        let result: Result<UserDTO, Error> = await networkService.fetch(path: "users/\(userId)")
        
        switch result {
            
        case let .success(response):
            
            guard let headerImageUrl = URL(string: response.headerImageUrl) else {
                
                return .failure(ParsingErrors.url)
            }
            guard let avatarImageUrl = URL(string: response.avatarImageUrl) else {
                
                return .failure(ParsingErrors.url)
            }
            
            let user: User = User(
                id: response.id,
                displayName: response.displayName,
                userName: response.userName,
                headerImageUrl: headerImageUrl,
                headerImageBackground: response.headerImageBackground,
                avatarImageUrl: avatarImageUrl,
                avatarImageBackground: response.avatarImageBackground,
                bio: response.bio
            )
            
            userCache.append((Date(), user))
            
            return .success(user)
            
        case let .failure(error):
            
            return .failure(error)
        }
    }
    
    func fetchUserStories(userId: String) async -> Result<[Story], Error> {
        
        clearStoryCache()
        
        if let (_, _, stories) = storyCache.first(where: { $0.1 == userId } ) {
            
            return .success(stories)
        }
        
        let result: Result<UserStoriesDTO, Error> = await networkService.fetch(path: "users/\(userId)/stories?limit=200")
        
        switch result {
            
        case let .success(response):
            
            var stories: [Story] = []
            
            for story in response.stories {
                
                guard let coverUrl = URL(string: story.coverSource) else {
                    
                    assertionFailure("Cannot map required properties")
                    continue
                }
                
                stories.append(
                    Story(
                        id: story.id,
                        title: story.title,
                        coverSource: coverUrl,
                        coverBackground: story.coverBackground,
                        commentCount: story.commentCount,
                        likes: story.likes.count,
                        aspectRatio: AspectRatio(rawValue: story.aspectRatio) ?? .nineToSixteen
                    ))
            }
            
            storyCache.append((Date(), userId, stories))
            
            return .success(stories)
            
        case let .failure(error):
            
            return .failure(error)
        }
    }
}

// MARK: - Cache methods

private extension UserService {
    
    func clearUserCache() {
        
        for (date, user) in userCache {
            
            let elapsed = abs(Date().timeIntervalSince(date))
            print("user cache: " + String(elapsed))
            
            if elapsed > 10 {
                
                userCache.removeAll(where: { $0.1.id == user.id })
                print("cache record removed")
            }
        }
    }
    
    func clearStoryCache() {
        
        for (date, userId, _) in storyCache {
            
            let elapsed = abs(Date().timeIntervalSince(date))
            print("story cache: " + String(elapsed))
            
            if elapsed > 10 {
                
                storyCache.removeAll(where: { $0.1 == userId } )
                print("story cache removed")
            }
        }
    }
}

// MARK: - Errors

private extension UserService {
    
    enum ParsingErrors: Error {
        
        case url
    }
}
