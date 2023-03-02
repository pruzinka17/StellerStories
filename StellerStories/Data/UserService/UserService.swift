//
//  UserService.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 18.02.2023.
//

import Foundation

final class UserService {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
        
        self.networkService = networkService
    }
}

private extension UserService {
    
    enum ParsingErrors: Error {
        
        case urlParsingError
    }
}

extension UserService {
    
    func fetchUser() async -> Result<User, Error> {
        
        let result: Result<UserDTO, Error> = await networkService.fetch(path: "users/76794126980351029")
        
        switch result {
            
        case let .success(response):
            
            guard let headerImageUrl = URL(string: response.headerImageUrl) else {
                
                return .failure(ParsingErrors.urlParsingError)
            }
            guard let avatarImageUrl = URL(string: response.avatarImageUrl) else {
                
                return .failure(ParsingErrors.urlParsingError)
            }
            
            let user: User = User(
                id: response.id,
                displayName: response.displayName,
                userName: response.userName,
                headerImageUrl: headerImageUrl,
                headerImageBackground: response.headerImageBackground,
                avatarImageUrl: avatarImageUrl,
                avatarImageBackground: response.avatarImageBackground,
                bio: response.bio)
            
            return .success(user)
            
        case let .failure(error):
            
            return .failure(error)
        }
    }
    
    func fetchUserStories() async -> Result<[Story], Error> {
        
        let result: Result<UserStoriesDTO, Error> = await networkService.fetch(path: "users/76794126980351029/stories?limit=200")
        
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
