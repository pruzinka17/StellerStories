//
//  UserService.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 18.02.2023.
//

import Foundation

final class UserService {
    
    private let networkService: NetworkService
    
    private var cache: [(Date, User)]
    
    init(networkService: NetworkService) {
        
        self.networkService = networkService
        self.cache = []
    }
}

private extension UserService {
    
    func checkCache() {
        
        for record in cache {
            
            let elapsed = Date().timeIntervalSince(record.0)
            print(elapsed)
            
            if elapsed > 10 {
                
                cache.removeAll(where: { $0.1.id == record.1.id })
                print("cache record removed")
            }
        }
    }
}

extension UserService {
    
    func fetchUser(userId: String) async -> Result<User, Error> {
        
        checkCache()
        
        let result: Result<UserDTO, Error> = await networkService.fetch(path: "users/\(userId)")
        
        switch result {
            
        case let .success(response):
            
            if cache.contains(where: { $0.1.id == response.id } ) {
                
                guard let user = cache.first(where: { $0.1.id == response.id } )?.1 else {
                    
                    return .failure(ParsingErrors.url)
                }
                
                return .success(user)
            }
            
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
            
            cache.append((Date(), user))
            
            return .success(user)
            
        case let .failure(error):
            
            return .failure(error)
        }
    }
    
    func fetchUserStories(userId: String) async -> Result<[Story], Error> {
        
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
            
            return .success(stories)
        case let .failure(error):
            
            return .failure(error)
        }
    }
}

// MARK: - Errors

private extension UserService {
    
    enum ParsingErrors: Error {
        
        case url
    }
}
