//
//  UserListPresenter.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 02.03.2023.
//

import Foundation

final class UserListPresenter: ObservableObject {
    
    let userService: UserService
    private let userIds: [String]
    
    @Published var viewModel: UserListViewModel
    
    @Published var userPresented: String
    
    @Published var isPresentingProfile: Bool
    
    init(userService: UserService, context: UserListContext) {
        
        self.userIds = context.userIds
        self.userService = userService
        self.viewModel = UserListViewModel(
            users: []
        )
        self.userPresented = ""
        self.isPresentingProfile = false
    }
}

extension UserListPresenter {
    
    func present() {
        
        Task {
            
            await fetch()
        }
    }
    
    func makeProfileContext() -> ProfileContext {
        
        return ProfileContext(userId: userPresented)
    }
}

private extension UserListPresenter {
    
    func fetch() async {
        
        for userId in userIds {
            
            let result = await userService.fetchUser(userId: userId)
            
            switch result {
            case let .success(value):
                
                let user = UserListViewModel.User(
                    id: value.id,
                    displayName: value.displayName,
                    userName: value.userName,
                    avatarURL: value.avatarImageUrl,
                    avatarBackground: value.avatarImageBackground
                )
                
                DispatchQueue.main.async { [weak self] in
                    
                    self?.viewModel.users.append(user)
                }
                
            case let .failure(error):
                print(error)
            }
        }
    }
}
