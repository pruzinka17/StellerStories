//
//  ProfileView.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 18.02.2023.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(\.dismiss) var dismissCurrentView
    
    @ObservedObject var presenter: ProfilePresenter
    
    init(userService: UserService, profileContext: ProfileContext) {

        self.presenter = ProfilePresenter(
            userService: userService,
            context: profileContext
        )
    }
    
    var body: some View {
        
        ZStack {
            
            GeometryReader { proxy in
                
                let frame = proxy.frame(in: .local)
                
                VStack {
                    
                    makeTopBar(safeArea: proxy.safeAreaInsets)
                    makeStoriesStrip(frame: frame)
                }
                .ignoresSafeArea()
            }
        }
        .fullScreenCover(
            
            isPresented: $presenter.isPresentingStories,
            content: {
                
                StoriesView(
                    context: presenter.makeStoriesContext(),
                    eventHadler: presenter.makeStoriesEventHandler()
                )
            })
        .onAppear {
            
            presenter.present()
        }
    }
}

// MARK: - TopBar

private extension ProfileView {
    
    @ViewBuilder func makeTopBar(safeArea: EdgeInsets) -> some View {
        
        ZStack {
            
            switch presenter.viewModel.state {
            case .loading:
                
                ProgressView()
                    .padding(.top, safeArea.top)
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
                .padding(.top, safeArea.top)
            case .failure:
                
                ZStack {
                    
                    Color.red
                    
                    Text(Constants.Text.connectionErrorText)
                        .padding(.top, safeArea.top)
                }
                
            }
        }
        .shadow(radius: 5)
        .frame(height: safeArea.top + Constants.Padding.topBarTopPadding)
        .ignoresSafeArea()
    }
    
    @ViewBuilder func makeUserInfo(user: ProfileViewModel.User) -> some View {
            
        Image(systemName: Constants.SymbolIds.returnArrowSymbol)
            .font(.Shared.returnArrow)
            .foregroundColor(.white)
            .frame(
                width: Constants.Sizes.returnArrowWidth,
                height: Constants.Sizes.returnArrowHeight
            )
            .onTapGesture {
                
                dismissCurrentView()
            }
        
        VStack {
            
            AsyncImage(url: user.avatarImageUrl) { image in
                
                image.resizable().clipShape(Circle())
            } placeholder: {
                
                Color(hex: user.avatarImageBackground).clipShape(Circle())
            }
        }
        .frame(
            width: Constants.Sizes.avatarSize,
            height: Constants.Sizes.avatarSize
        )
        
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
        
        RoundedRectangle(cornerRadius: Constants.Radiuses.followButtonRadius)
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
            .frame(
                width: Constants.Sizes.followButttonWidth,
                height: Constants.Sizes.followButtonHeight
            )
        
        Circle()
            .foregroundColor(Color.secondary)
            .overlay {
                
                Image(systemName: Constants.SymbolIds.moreInfoSymbol)
                    .foregroundColor(Color.white)
                    .rotationEffect(.degrees(-90))
            }
            .frame(height: Constants.Sizes.moreActionsButtonSize)
    }
}

// MARK: - Stories strip

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
                .frame(height: Constants.Sizes.storyHeight)
            case let .populated(stories):
                
                var storyStripWidth: CGFloat = 0
                
                ScrollViewReader { value in
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        
                        ZStack {
                         
                            HStack {
                                
                                ForEach(stories, id: \.id) { story in
                                    
                                    makeStoryItem(story: story, frame: frame)
                                }
                            }
                            .padding([.leading], Constants.Padding.storiesStackPadding)
                            
                            GeometryReader { proxy in
                                
                                Color.clear
                                    .preference(
                                        key: OffsetPreferenceKey.self,
                                        value: proxy.frame(in: .named("StoriesScroll")).minX
                                    )
                                    .onAppear {
                                        
                                        storyStripWidth = proxy.size.width
                                    }
                            }.frame(height: 0)
                        }
                    }
                    .coordinateSpace(name: "StoriesScroll")
                    .onPreferenceChange(OffsetPreferenceKey.self, perform: { value in
                        
                        presenter.handleEvent(.didScrollStories(value * -1, storyStripWidth))
                        print(value * -1)
                    })
                    .onReceive(presenter.$initialStoryId) { id in
                        
                        value.scrollTo(id, anchor: .trailing)
                    }
                }
            case .failure:
                
                HStack {
                    
                    Text(Constants.Text.connectionErrorText)
                }
                .frame(height: Constants.Sizes.storyHeight)
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
                        .clipShape(
                            RoundedRectangle(cornerRadius: Constants.Radiuses.storiesCornerRadius)
                        )
            } placeholder: {
                
                Color(hex: story.coverBackground)
            }
        }
        .overlay(alignment: .bottomTrailing, content: {
            
            let commentCount = story.commentCount
            let likes = story.likes
            
            HStack {
                
                if commentCount > 0 {
                    
                    Label("\(commentCount)", systemImage: Constants.SymbolIds.commentSymbol)
                        .foregroundColor(.white)
                        .font(.Shared.claps)
                }
                
                if likes > 0 {
                    
                    Label("\(likes)", systemImage: Constants.SymbolIds.handClapSymbol)
                        .foregroundColor(.white)
                        .font(.Shared.claps)
                }
            }
            .padding([.trailing, .bottom], Constants.Padding.storiesStatsPadding)
        })
        .onTapGesture {
            
            presenter.initialStoryId = story.id
            presenter.isPresentingStories = true
        }
        .clipShape(RoundedRectangle(cornerRadius: Constants.Radiuses.storiesCornerRadius))
        .frame(
            
            width: Constants.Sizes.storyHeight / 16 * 9,
            height: Constants.Sizes.storyHeight
        )
    }
}

// MARK: - Constants

private extension ProfileView {

    enum Constants {
        
        enum Text {
            
            static let connectionErrorText: String = "connection error"
            static let followActionButtonText: String = "Follow"
            static let storiesSectionHeader: String = "Stories"
        }
        
        enum Padding {
            
            static let topBarTopPadding: CGFloat = 75
            static let storiesStackPadding: CGFloat = 6
            static let storiesStatsPadding: CGFloat = 10
        }
        
        enum SymbolIds {
            
            static let returnArrowSymbol: String = "chevron.backward"
            static let plusSymbol: String = "plus"
            static let moreInfoSymbol: String = "ellipsis"
            static let handClapSymbol: String = "hands.clap.fill"
            static let commentSymbol: String = "bubble.left.fill"
        }
        
        enum Radiuses {
            
            static let storiesCornerRadius: CGFloat = 15
            static let followButtonRadius: CGFloat = 20
        }
        
        enum Sizes {
            
            static let storyHeight: CGFloat = 355
            static let avatarSize: CGFloat = 55
            static let returnArrowWidth: CGFloat = 20
            static let returnArrowHeight: CGFloat = 30
            static let followButttonWidth: CGFloat = 80
            static let followButtonHeight: CGFloat = 32
            static let moreActionsButtonSize: CGFloat = 33
        }
    }
}
