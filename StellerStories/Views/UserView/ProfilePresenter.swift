//
//  ProfilePresenter.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 18.02.2023.
//

import Foundation

enum ProfileViewEvents {
    
    case didScrollStories(Double, Double)
}

final class ProfilePresenter: ObservableObject {
    
    private let userService: UserService
    
    private let userId: String
    
    private var stories: [Story]
    private var storiesCursor: String?
    private var isFetchingMoreStories: Bool
    
    
    @Published var viewModel: ProfileViewModel
    @Published var isPresentingStories: Bool
    @Published var initialStoryId: String
    
    init(
        userService: UserService,
        context: ProfileContext
    ) {
        
        self.userService = userService
        
        self.userId = context.userId
        
        self.isFetchingMoreStories = false
        self.stories = []
        self.storiesCursor = nil
        
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
    
    func handleEvent(_ event: ProfileViewEvents) {
        
        switch event {
        case let .didScrollStories(offset, storyStripWidth):
            
            guard offset / storyStripWidth > 0.7 else {
                return
            }
            
            Task {
                
                await fetchMoreUserStories()
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
        
        let result = await userService.fetchUserStories(userId: userId)
        
        switch result {
        case let .success((stories, cursor)):
            
            self.stories = stories
            self.storiesCursor = cursor
            
            DispatchQueue.main.async { [weak self] in
                
                self?.populateStories()
            }
        case let.failure(error):
            
            DispatchQueue.main.async { [weak self] in
                
                self?.viewModel.storiesState = .failure
            }
            
            print(error)
        }
    }
    
    func fetchMoreUserStories() async {
        
        guard
            let storiesCursor = storiesCursor,
            !isFetchingMoreStories
        else {
            return
        }
        
        isFetchingMoreStories = true
        
        let result = await userService.fetchUserStories(
            userId: userId,
            afterCursor: storiesCursor
        )
        
        isFetchingMoreStories = false
        
        switch result {
        case let .success((stories, cursor)):
            
            self.stories.append(contentsOf: stories)
            self.storiesCursor = cursor
            
            DispatchQueue.main.async { [weak self] in
                
                self?.populateStories()
            }
        case let .failure(error):
            
            print(error)
        }
    }
    
    func populateStories() {
        
        let items = stories.map({ story in
            
            ProfileViewModel.Story(
                id: story.id,
                coverSource: story.coverSource,
                coverBackground: story.coverBackground,
                commentCount: story.commentCount,
                likes: story.likes,
                aspectRatio: story.aspectRatio
            )
        })
        
        viewModel.storiesState = .populated(items)
    }
}

