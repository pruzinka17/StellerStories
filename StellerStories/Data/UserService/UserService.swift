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
    
    func fetchUser() async -> Result<User, Error> {
        
        let result: Result<UserDTO, Error> = await networkService.fetch(path: "76794126980351029")
        
        switch result {
            
        case let .success(response):
            
            let user: User = User(
                id: response.id,
                displayName: response.displayName,
                userName: response.userName,
                headerImageUrl: response.headerImageUrl,
                headerImageBackground: response.headerImageBackground,
                avatarImageUrl: response.avatarImageUrl,
                avatarImageBackground: response.avatarImageBackground,
                bio: response.bio)
            
            return .success(user)
            
        case let .failure(error):
            
            return .failure(error)
        }
    }
    
    func fetchUserStories() async -> Result<[Story], Error> {
        
        let result: Result<UserStoriesDTO, Error> = await networkService.fetch(path: "76794126980351029/stories")
        
        switch result {
            
        case let .success(response):
            
            var stories: [Story] = []
            
            for story in response.stories {
                
                stories.append(
                    Story(
                        id: story.id,
                        coverSource: story.coverSource,
                        coverBackground: story.coverBackground,
                        title: story.title,
                        commentCount: story.commentCount,
                        aspectRatio: story.aspectRatio,
                        likes: story.likes.count
                    ))
            }
            
            return .success(stories)
        
        case let .failure(error):
            
            return .failure(error)
        }
    }
}
