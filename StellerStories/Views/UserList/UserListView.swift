//
//  UserListView.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 02.03.2023.
//

import SwiftUI

struct UserListView: View {
    
    private let collectionsManager: CollectionsManager
    
    @ObservedObject var presenter: UserListPresenter
    
    init(userService: UserService, collectionsManager: CollectionsManager, userListContext: UserListContext) {
        
        self.collectionsManager = collectionsManager
        self.presenter = UserListPresenter(
            userService: userService,
            context: userListContext
        )
    }
    
    var body: some View {
        
        GeometryReader { proxy in
            
            let frame = proxy.frame(in: .local)
            
            ZStack {
                
                makeUserList(frame: frame)
            }
            .fullScreenCover(isPresented: $presenter.isPresentingProfile, content: {
                
                ProfileView(userService: presenter.userService, collectionsManager: collectionsManager, profileContext: presenter.makeProfileContext())
            })
            .onAppear {
                
                presenter.present()
            }
        }
    }
}

// MARK: - UserList

private extension UserListView {
    
    @ViewBuilder func makeUserList(frame: CGRect) -> some View {
        
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
        .listStyle(.plain)
    }
}
