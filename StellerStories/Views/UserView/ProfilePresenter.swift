//
//  ProfilePresenter.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 18.02.2023.
//

import Foundation

enum ProfileViewEvents {
    
    case didScrollStories
}

final class ProfilePresenter: ObservableObject {
    
    private let userService: UserService
    
    private var stories: [Story]
    
    private var cursor: String?
    
    private let userId: String
    
    @Published var viewModel: ProfileViewModel
    @Published var isPresentingStories: Bool
    @Published var initialStoryId: String
    
    @Published var position: CGFloat
    @Published var contentWidth: CGFloat
    
    init(
        userService: UserService,
        context: ProfileContext
    ) {
        
        self.userService = userService
        
        self.stories = []
        
        self.userId = context.userId
        
        self.viewModel = ProfileViewModel(
            state: .loading,
            storiesState: .loading
        )
        
        self.isPresentingStories = false
        self.initialStoryId = ""
        
        self.position = 0
        self.contentWidth = 0
    }
}

// MARK: - Public methods

extension ProfilePresenter {
    
    func present() {
        
        Task {
            
            await fetch()
        }
    }
    
    func handleEvent(_ event: ProfileViewEvents) {
        
        switch event {
        case .didScrollStories:
            if position / contentWidth > 0.7 {
                
                Task {
                    
                    print("fetching more stories")
                    await fetchUserStories()
                }
            }
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
        
        let result = await userService.fetchUserStories(userId: userId, afterCursor: cursor)
        
        switch result {
        case let .success((stories, cursor)):
            
            self.stories = stories
            self.cursor = cursor
            
            DispatchQueue.main.async { [weak self] in
                
                self?.viewModel.storiesState = .populated(
                    stories.map({ story in
                        ProfileViewModel.Story(
                            id: story.id,
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

