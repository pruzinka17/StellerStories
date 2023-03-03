//
//  UserListView.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 02.03.2023.
//

import SwiftUI

struct UserListView: View {
    
    @ObservedObject var presenter: UserListPresenter
    
    init(userService: UserService) {
        self.presenter = UserListPresenter(
            userService: userService,
            userIds: ["812249714027136186", "76794126980351029"]
        )
    }
    
    var body: some View {
        
        switch presenter.viewModel.usersState {
        case .loading:
            Text("loading")
            
        case let .populated(users):
            List {
                
                ForEach(users) { user in
                    
                    HStack {
                        
                        Text(user.userName)
                        
                        Text(user.displayName)
                    }
                }
            }
            
        case.failure:
            
            Text("loadFailed")
        }
    }
}

struct UserListView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        UserListView(
            userService: UserService(networkService: NetworkService())
        )
    }
}
