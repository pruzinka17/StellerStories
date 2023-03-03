//
//  UserListPresenter.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 02.03.2023.
//

import Foundation

final class UserListPresenter: ObservableObject {
    
    private let userService: UserService
    private let userIds: [String]
    
    @Published var viewModel: UserListViewModel
    
    init(userService: UserService, userIds: [String]) {
        
        self.userIds = userIds
        self.userService = userService
        self.viewModel = UserListViewModel(
            usersState: .loading
        )
    }
}

private extension UserListPresenter {
    
    func fetch() async {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.viewModel.usersState = .loading
        }
        
        for user in userIds {
            
            let result = await userService.fetchUser(userId: user)
        }
    }
}
