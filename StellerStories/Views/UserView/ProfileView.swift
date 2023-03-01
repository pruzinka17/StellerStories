//
//  UserView.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 18.02.2023.
//

import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var presenter: UserPresenter
    
    init(userService: UserService) {
        
        self.presenter = UserPresenter(
            userService: userService
        )
    }
    
    var body: some View {
        
        ZStack {
            
            GeometryReader { proxy in
                
                let frame = proxy.frame(in: .local)
                
                VStack {
                    
                    userBar(proxy: proxy)
                    
                    makeStoriesSelection(frame: frame)
                }
                .ignoresSafeArea()
            }
        }
        .fullScreenCover(isPresented: $presenter.isPresentingStories, content: {

            StoriesView(context: presenter.generateStoriesContext())
        })
        .task {
            
            await self.presenter.fetch()
        }
    }
}

//MARK: - userBar

private extension ProfileView {
    
    @ViewBuilder func userBar(proxy: GeometryProxy) -> some View {
        
        ZStack {
            
            switch presenter.viewModel.state {
            case .loading:
                ProgressView()
                    .padding(.top, proxy.safeAreaInsets.top)
                
            case .populated:
                
                ZStack {
                    
                    AsyncImage(url: URL(string: presenter.viewModel.user.headerImageUrl)) { image in
                        
                        image.resizable()
                    } placeholder: {
                        
                        Color(hex: presenter.viewModel.user.headerImageBackground)
                    }
                    .ignoresSafeArea()
                    
                    HStack {
                        
                        makeUserInfo()
                        
                        Spacer()
                        
                        makeUserActions()
                    }
                    .padding()
                }
                .padding(.top, proxy.safeAreaInsets.top)
                
            case .failure:
                ZStack {
                    
                    Color.red
                    
                    Text("connection error")
                        .padding(.top, proxy.safeAreaInsets.top)
                }
                
            }
        }
        .shadow(radius: 5)
        .frame(width: proxy.frame(in: .local).width, height: proxy.safeAreaInsets.top + 75)
        .ignoresSafeArea()
    }
    
    //MARK: - userInfo
    
    @ViewBuilder func makeUserInfo() -> some View {
            
        Image(systemName: "chevron.backward")
            .font(.system(size: 26, weight: .light))
            .foregroundColor(.white)
            .frame(width: 20, height: 30)
        
        VStack {
            
            AsyncImage(url: URL(string: presenter.viewModel.user.avatarImageUrl)) { image in
                
                image.resizable().clipShape(Circle())
            } placeholder: {
                
                Color(hex: presenter.viewModel.user.avatarImageBackground).clipShape(Circle())
            }
        }
        .frame(width: 55, height: 55)
        
        VStack(alignment: .leading) {
            
            Text(presenter.viewModel.user.userName)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .bold))
            
            Text(presenter.viewModel.user.displayName)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .light))
        }
    }
    
    //MARK: - userActions
    
    @ViewBuilder func makeUserActions() -> some View {
        
        RoundedRectangle(cornerRadius: 20)
            .foregroundColor(Color.secondary)
            .overlay {
                
                HStack {
                    
                    Image(systemName: "plus")
                        .foregroundColor(Color.white)
                    
                    Text("Follow")
                        .font(.system(size: 13, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
            }
            .frame(width: 80, height: 32)
        
        Circle()
            .foregroundColor(Color.secondary)
            .overlay {
                
                Image(systemName: "ellipsis")
                    .foregroundColor(Color.white)
                    .rotationEffect(.degrees(-90))
            }
            .frame(height: 33)
    }
}

//MARK: - Stories Selection

private extension ProfileView {
    
    //MARK: - selection
    
    @ViewBuilder func makeStoriesSelection(frame: CGRect) -> some View {
        
        VStack {
            
            HStack {

                Text("Stories")
                    .font(.system(size: 28, weight: .black, design: .default))

                Spacer()
            }
            .padding([.leading, .top])
                    
            switch presenter.viewModel.storiesState {
            case .loading:
                HStack(alignment: .center) {
                    
                    ProgressView()
                }
                .frame(height: 350)
                
            case .populated:
                ScrollView(.horizontal, showsIndicators: false) {
                    
                    HStack {
                        
                        ForEach(presenter.viewModel.stories, id: \.coverSource) { story in
                            
                            makeStory(story: story, frame: frame)
                        }
                    }
                    .padding([.leading], 8)
                }
                
            case .failure:
                HStack {
                    
                    Text("loading failed")
                }
                .frame(height: 350)
            }
        }
    }
    
    //MARK: - story
    
    @ViewBuilder func makeStory(story: Story, frame: CGRect) -> some View {
        
        ZStack {
            
            Color(hex: story.coverBackground)
             
            AsyncImage(url: URL(string: story.coverSource)) { image in
                    
                    image
                        .resizable()
                        .scaledToFit()
            } placeholder: {
                
                Color(hex: story.coverBackground)
            }
        }
        .overlay(alignment: .bottomTrailing, content: {
            
            Label(String(story.likes), systemImage: "hands.clap.fill")
                .foregroundColor(.white)
                .font(.system(size: 14))
                .padding([.trailing, .bottom], 10)
        })
        .onTapGesture {
            
            presenter.initialStoryId = story.id
            presenter.isPresentingStories = true
        }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .frame(width: Constants.storyWidth, height: Constants.storyWidth * 16 / 9)
    }
}

//MARK: - Constants

private extension ProfileView {

    enum Constants {

        static let storyWidth: CGFloat = 200
    }
}

struct ProfileView_Previews: PreviewProvider {

    static var previews: some View {

        ProfileView(userService: UserService(networkService: NetworkService()))
    }
}
