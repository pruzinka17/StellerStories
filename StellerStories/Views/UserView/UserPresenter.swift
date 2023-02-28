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
    
    init(userService: UserService) {
        
        self.userService = userService
        
        self.viewModel = UserViewModel(
            userFetchFailed: false,
            storiesFetchFailed: false,
            isPresentingStories: false,
            presentedStoryId: "",
            user: UserViewModel.User(
                displayName: "",
                userName: "",
                headerImageUrl: "",
                headerImageBackground: "",
                avatarImageUrl: "",
                avatarImageBackground: ""
            ),
            stories: []
        )
    }
}

//MARK: - fetching functions

extension UserPresenter {
    
    func fetchUser() async {
        
        let result = await userService.fetchUser()
        
        switch result {
            
        case let .success(user):
            
            DispatchQueue.main.async { [weak self] in
                
                self?.viewModel.user = UserViewModel.User(
                    displayName: user.displayName,
                    userName: user.userName,
                    headerImageUrl: user.headerImageUrl,
                    headerImageBackground: user.headerImageBackground,
                    avatarImageUrl: user.avatarImageUrl,
                    avatarImageBackground: user.avatarImageBackground)
            }
            
        case let .failure(error):
            
            DispatchQueue.main.async { [weak self] in
                
                self?.viewModel.error = error
                self?.viewModel.userFetchFailed = true
            }
        }
    }
    
    func fetchUserStories() async {
        
        let result = await userService.fetchUserStories()
        
        switch result {
            
        case let .success(values):
            
            let stories: [UserViewModel.Story] = values.map {
                
                UserViewModel.Story(
                    id: $0.id,
                    coverSource: $0.coverSource,
                    coverBackground: $0.coverBackground,
                    commentCount: $0.commentCount,
                    aspectRatio: $0.aspectRatio,
                    likes: $0.likes
                )
            }
            
            DispatchQueue.main.async { [weak self] in
                
                self?.viewModel.stories = stories
            }
            
        case let.failure(error):
            
            DispatchQueue.main.async { [weak self] in
                
                self?.viewModel.error = error
                self?.viewModel.storiesFetchFailed = true
            }
        }
    }
}

