//
//  UserPresenter.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 18.02.2023.
//

import Foundation

final class UserPresenter: ObservableObject {
    
    private let userService: UserService
    
    @Published var viewModel: UserViewModel
    
    @Published var isPresentingStories: Bool
    
    @Published var initialStoryId: String
    
    init(userService: UserService) {
        
        self.userService = userService
        
        self.viewModel = UserViewModel(
            state: .loading,
            storiesState: .loading,
            user: User(
                id: "",
                displayName: "",
                userName: "",
                headerImageUrl: "",
                headerImageBackground: "",
                avatarImageUrl: "",
                avatarImageBackground: "",
                bio: ""
            ),
            stories: []
        )
        
        self.isPresentingStories = false
        self.initialStoryId = ""
    }
}

//MARK: - public methods

extension UserPresenter {
    
    func generateStoriesContext() -> StoriesContext {
        
        let context: StoriesContext = StoriesContext(intialStoryId: initialStoryId, stories: viewModel.stories)
        return context
    }
}

//MARK: - fetching methods

extension UserPresenter {
    
    //MARK: - fetch profile data
    
    func fetch() async {
        
        let result = await userService.fetchUser()
        
        switch result {
            
        case let .success(user):
            
            DispatchQueue.main.async { [weak self] in
                
                self?.viewModel.user = User(
                    id: user.id,
                    displayName: user.displayName,
                    userName: user.userName,
                    headerImageUrl: user.headerImageUrl,
                    headerImageBackground: user.headerImageBackground,
                    avatarImageUrl: user.avatarImageUrl,
                    avatarImageBackground: user.avatarImageBackground,
                    bio: user.bio
                )
                
                self?.viewModel.state = .populated
            }
            
            await fetchUserStories()
            
        case let .failure(error):
            
            DispatchQueue.main.async { [weak self] in
                
                self?.viewModel.state = .failure
                self?.viewModel.storiesState = .failure
            }
        }
    }
    
    //MARK: - fetch profile stories
    
    func fetchUserStories() async {
        
        let result = await userService.fetchUserStories()
        
        switch result {
        case let .success(models):
            
            let stories: [Story] = models.map { model in
                
                Story(
                    id: model.id,
                    coverSource: model.coverSource,
                    coverBackground: model.coverBackground,
                    title: model.title,
                    commentCount: model.commentCount,
                    aspectRatio: model.aspectRatio,
                    likes: model.likes
                )
            }
            
            DispatchQueue.main.async { [weak self] in
                
                self?.viewModel.stories = stories
                self?.viewModel.storiesState = .populated
            }
        case let.failure(error):
            
            DispatchQueue.main.async { [weak self] in
                
                self?.viewModel.storiesState = .failure
            }
        }
    }
}

