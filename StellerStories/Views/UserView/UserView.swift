//
//  UserView.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 18.02.2023.
//

import SwiftUI

struct UserView: View {
    
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
            }
        }
        .fullScreenCover(isPresented: $presenter.viewModel.isPresentingStories, content: {

            StoriesView(
                
                viewModel: $presenter.viewModel
            )
        })
        .task {
            
            await self.presenter.fetchUser()
            await self.presenter.fetchUserStories()
        }
    }
}

//MARK: - userBar

private extension UserView {
    
    @ViewBuilder func userBar(proxy: GeometryProxy) -> some View {
        
        ZStack {
            
            ZStack {
                
                AsyncImage(url: URL(string: presenter.viewModel.user.headerImageUrl)) { image in
                    
                    image.resizable()
                } placeholder: {
                    
                    Color(hex: presenter.viewModel.user.headerImageBackground)
                }
                .ignoresSafeArea()
                
                HStack {
                    
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
                    
                    Spacer()
                    
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
                .padding()
            }
            .padding(.top, proxy.safeAreaInsets.top)
        }
        .shadow(radius: 5)
        .frame(height: proxy.safeAreaInsets.top + 75)
        .ignoresSafeArea()
    }
}

//MARK: - Stories Selection

private extension UserView {
    
    @ViewBuilder func makeStoriesSelection(frame: CGRect) -> some View {
        
        VStack {
            
            HStack {
                
                Text("Stories")
                    .font(.system(size: 28, weight: .black, design: .default))
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack {
                    
                    ForEach(presenter.viewModel.stories, id: \.coverSource) { story in
                        
                        makeStory(story: story)
                    }
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder func makeStory(story: UserViewModel.Story) -> some View {
        
        ZStack(alignment: .bottomTrailing) {
                        
            AsyncImage(url: URL(string: story.coverSource)) { image in
                
                image.resizable()
            } placeholder: {
                
                Color(hex: story.coverBackground)
            }
                
            Label(String(story.likes), systemImage: "hands.clap.fill")
                .foregroundColor(.white)
                .font(.system(size: 14))
                .padding([.trailing, .bottom], 10)
            
        }
        .onTapGesture {
            
            presenter.viewModel.presentedStoryId = story.id
            presenter.viewModel.isPresentingStories = true
        }
        .frame(width: 200, height: 355.5)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

//MARK: - Color convertor

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct UserView_Previews: PreviewProvider {

    static var previews: some View {

        UserView(userService: UserService(networkService: NetworkService()))
    }
}
