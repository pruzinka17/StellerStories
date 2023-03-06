//
//  ProfilePresenter.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 18.02.2023.
//

import Foundation

final class ProfilePresenter: ObservableObject {
    
    private let userService: UserService
    
    private var stories: [Story]
    
    private let userId: String
    
    @Published var viewModel: ProfileViewModel
    @Published var isPresentingStories: Bool
    @Published var initialStoryId: String
    
    init(userService: UserService, userId: String) {
        
        self.userService = userService
        
        self.stories = []
        
        self.userId = userId
        
        self.viewModel = ProfileViewModel(
            state: .loading,
            storiesState: .loading
        )
        
        self.isPresentingStories = false
        self.initialStoryId = ""
    }
}

// MARK: - Public methods

extension ProfilePresenter {
    
    func present() {
        
        Task {
            
            await fetch()
        }
    }
    
    func makeStoriesContext() -> StoriesContext {
        
        return StoriesContext(
            intialStoryId: initialStoryId,
            stories: stories
        )
    }
    
    func makeStoriesEventHandler() -> StoriesEventHandler {
        
        return StoriesEventHandler(
            
            onStoryIdChange: { [weak self] id in
                
                guard self?.initialStoryId != id else {
                    return
                }
                
                self?.initialStoryId = id
            }
        )
    }
}

// MARK: - Fetching methods

private extension ProfilePresenter {
    
    func fetch() async {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.viewModel.state = .loading
            
        }

        let result = await userService.fetchUser(userId: userId)
        
        switch result {
        case let .success(user):
            
            DispatchQueue.main.async { [weak self] in
                
                let user = ProfileViewModel.User(
                    displayName: user.displayName,
                    userName: user.userName,
                    headerImageUrl: user.headerImageUrl,
                    headerImageBackground: user.headerImageBackground,
                    avatarImageUrl: user.avatarImageUrl,
                    avatarImageBackground: user.avatarImageBackground,
                    bio: user.bio
                )
                
                self?.viewModel.state = .populated(user)
            }
            
            await fetchUserStories()
        case let .failure(error):
            
            DispatchQueue.main.async { [weak self] in
                
                self?.viewModel.state = .failure
                self?.viewModel.storiesState = .failure
            }
            
            print(error)
        }
    }
    
    func fetchUserStories() async {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.viewModel.storiesState = .loading
        }
        
        let result = await userService.fetchUserStories(userId: userId)
        
        switch result {
        case let .success(stories):
            
            self.stories = stories
            
            DispatchQueue.main.async { [weak self] in
                
                self?.viewModel.storiesState = .populated(
                    stories.map({ story in
                        ProfileViewModel.Story(
                            id: story.id,
                            title: story.title,
                            coverSource: story.coverSource,
                            coverBackground: story.coverBackground,
                            commentCount: story.commentCount,
                            likes: story.likes,
                            aspectRatio: story.aspectRatio
                        )
                    })
                )
            }
        case let.failure(error):
            
            DispatchQueue.main.async { [weak self] in
                
                self?.viewModel.storiesState = .failure
            }
            
            print(error)
        }
    }
}

