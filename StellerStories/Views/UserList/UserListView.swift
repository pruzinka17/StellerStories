//
//  UserListView.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 02.03.2023.
//

import SwiftUI

struct UserListView: View {
    
    @ObservedObject var presenter: UserListPresenter
    
    init(userService: UserService, userIds: [String]) {
        self.presenter = UserListPresenter(
            userService: userService,
            userIds: userIds
        )
    }
    
    var body: some View {
        
        ZStack {
            
            makeUserList()
        }
        .fullScreenCover(isPresented: $presenter.isPresentingProfile, content: {
            
            ProfileView(userService: presenter.userService, userId: presenter.userPresented)
        })
        .onAppear {
            
            presenter.present()
        }
    }
}

// MARK: - UserList

private extension UserListView {
    
    @ViewBuilder func makeUserList() -> some View {
        
        List {
            
            ForEach(presenter.viewModel.users, id: \.id) { user in
                
                HStack {
                    
                    VStack {
                        
                        AsyncImage(url: user.avatarURL) { image in
                            
                            image
                                .resizable()
                                .clipShape(Circle())
                        } placeholder: {
                            
                            Color(hex: user.avatarBackground)
                                .clipShape(Circle())
                        }
                    }
                    .frame(width: 45, height: 45)
                    
                    VStack(alignment: .leading) {
                        
                        Text(user.userName)
                        
                        Text(user.displayName)

                    }
                }
                .onTapGesture {
                    
                    presenter.userPresented = user.id
                    presenter.isPresentingProfile = true
                }
            }
        }
    }
}
