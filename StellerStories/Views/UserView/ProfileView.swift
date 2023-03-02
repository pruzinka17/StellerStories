//
//  ProfileView.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 18.02.2023.
//

import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var presenter: ProfilePresenter
    
    init(userService: UserService) {
        
        self.presenter = ProfilePresenter(
            userService: userService
        )
    }
    
    var body: some View {
        
        ZStack {
            
            GeometryReader { proxy in
                
                let frame = proxy.frame(in: .local)
                
                VStack {
                    
                    makeTopBar(proxy: proxy)
                    makeStoriesStrip(frame: frame)
                }
                .ignoresSafeArea()
            }
        }
        .fullScreenCover(
            isPresented: $presenter.isPresentingStories,
            content: {

            StoriesView(
                context: presenter.makeStoriesContext()
            )
        })
        .onAppear {
            
            presenter.present()
        }
    }
}

// MARK: - TopBar

private extension ProfileView {
    
    @ViewBuilder func makeTopBar(proxy: GeometryProxy) -> some View {
        
        ZStack {
            
            switch presenter.viewModel.state {
            case .loading:
                
                ProgressView()
                    .padding(.top, proxy.safeAreaInsets.top)
            case let .populated(user):
                
                ZStack {
                    
                    AsyncImage(url: user.headerImageUrl) { image in
                        
                        image.resizable()
                    } placeholder: {
                        
                        Color(hex: user.headerImageBackground)
                    }
                    .ignoresSafeArea()
                    
                    HStack {
                        
                        makeUserInfo(user: user)
                        
                        Spacer()
                        
                        makeUserActions()
                    }
                    .padding()
                }
                .padding(.top, proxy.safeAreaInsets.top)
            case .failure:
                
                ZStack {
                    
                    Color.red
                    
                    Text(Constants.Text.connectionErrorText)
                        .padding(.top, proxy.safeAreaInsets.top)
                }
                
            }
        }
        .shadow(radius: 5)
        .frame(width: proxy.frame(in: .local).width, height: proxy.safeAreaInsets.top + 75)
        .ignoresSafeArea()
    }
    
    @ViewBuilder func makeUserInfo(user: ProfileViewModel.User) -> some View {
            
        Image(systemName: Constants.SymbolIds.returnArrowSymbol)
            .font(.Shared.returnArrow)
            .foregroundColor(.white)
            .frame(width: 20, height: 30)
        
        VStack {
            
            AsyncImage(url: user.avatarImageUrl) { image in
                
                image.resizable().clipShape(Circle())
            } placeholder: {
                
                Color(hex: user.avatarImageBackground).clipShape(Circle())
            }
        }
        .frame(width: 55, height: 55)
        
        VStack(alignment: .leading) {
            
            Text(user.userName)
                .foregroundColor(.white)
                .font(.Shared.userName)
            
            Text(user.displayName)
                .foregroundColor(.white)
                .font(.Shared.displayName)
        }
    }
    
    @ViewBuilder func makeUserActions() -> some View {
        
        RoundedRectangle(cornerRadius: 20)
            .foregroundColor(Color.secondary)
            .overlay {
                
                HStack {
                    
                    Image(systemName: Constants.SymbolIds.plusSymbol)
                        .foregroundColor(Color.white)
                    
                    Text(Constants.Text.followActionButtonText)
                        .font(.Shared.followButton)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            }
            .frame(width: 80, height: 32)
        
        Circle()
            .foregroundColor(Color.secondary)
            .overlay {
                
                Image(systemName: Constants.SymbolIds.moreInfoSymbol)
                    .foregroundColor(Color.white)
                    .rotationEffect(.degrees(-90))
            }
            .frame(height: 33)
    }
}

//MARK: - Stories strip

private extension ProfileView {
    
    @ViewBuilder func makeStoriesStrip(frame: CGRect) -> some View {
        
        VStack {
            
            HStack {

                Text(Constants.Text.storiesSectionHeader)
                    .font(.Shared.sectionHeader)

                Spacer()
            }
            .padding([.leading, .top])
                    
            switch presenter.viewModel.storiesState {
            case .loading:
                
                HStack(alignment: .center) {
                    
                    ProgressView()
                }
                .frame(height: Constants.storyHeight)
            case let .populated(stories):
                
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack {
                        
                        ForEach(stories, id: \.id) { story in
                            
                            makeStoryItem(story: story, frame: frame)
                        }
                    }
                    .padding([.leading], 8)
                }
                
            case .failure:
                HStack {
                    
                    Text(Constants.Text.connectionErrorText)
                }
                .frame(height: Constants.storyHeight)
            }
        }
    }
    
    @ViewBuilder func makeStoryItem(story: ProfileViewModel.Story, frame: CGRect) -> some View {
        
        ZStack {
            
            Color(hex: story.coverBackground)
             
            AsyncImage(url: story.coverSource) { image in
                    
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 15))
            } placeholder: {
                
                Color(hex: story.coverBackground)
            }
        }
        .overlay(alignment: .bottomTrailing, content: {
            
            Label(String(story.likes), systemImage: Constants.SymbolIds.handClapSymbol)
                .foregroundColor(.white)
                .font(.Shared.claps)
                .padding([.trailing, .bottom], 10)
        })
        .onTapGesture {
            
            presenter.initialStoryId = story.id
            presenter.isPresentingStories = true
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .frame(
            width: Constants.storyHeight / 16 * 9,
            height: Constants.storyHeight
        )
    }
}

//MARK: - Constants

private extension ProfileView {

    enum Constants {

        static let storyHeight: CGFloat = 355
        
        enum Text {
            
            static let connectionErrorText: String = "connection error"
            static let followActionButtonText: String = "Follow"
            static let storiesSectionHeader: String = "Stories"
        }
        
        enum SymbolIds {
            
            static let returnArrowSymbol: String = "chevron.backward"
            static let plusSymbol: String = "plus"
            static let moreInfoSymbol: String = "ellipsis"
            static let handClapSymbol: String = "hands.clap.fill"
        }
    }
}

struct ProfileView_Previews: PreviewProvider {

    static var previews: some View {

        ProfileView(userService: UserService(networkService: NetworkService()))
    }
}
