//
//  StoriesView.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 23.02.2023.
//

import SwiftUI

struct StoriesView: View {
    
    @ObservedObject var presenter: StoriesPresenter
    
    @Environment(\.dismiss) var dismissCurrentView
    
    init(context: StoriesContext) {
        
        self.presenter = StoriesPresenter(context: context)
    }
    
    var body: some View {
        
        GeometryReader { proxy in
            
            ZStack {
                
                Color(hex: presenter.viewModel.stories.first(where: { $0.id == presenter.viewModel.presentedStoryId } )?.coverBackground ?? Constants.defaultBackgroundColor)
                    .animation(.default, value: presenter.viewModel.presentedStoryId)
                    .ignoresSafeArea()
                
                VStack(alignment: .center) {
                    
                    TabView(selection: $presenter.viewModel.presentedStoryId) {

                        ForEach(presenter.viewModel.stories, id: \.id) { story in

                            makeStory(story: story, proxy: proxy)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                .frame(height: proxy.frame(in: .local).height)
            }
        }
    }
}

//MARK: - make story

private extension StoriesView {
    
    @ViewBuilder func makeStory(story: Story, proxy: GeometryProxy) -> some View {
        
        VStack(alignment: .center) {
            
            GeometryReader { proxy in
                    
                AsyncImage(url: URL(string: story.coverSource)) { image in
                    
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    
                    Color(hex: story.coverBackground)
                }
                .overlay(

                    Button {

                        withAnimation {

                            dismissCurrentView()
                        }
                    } label: {

                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding()

                    , alignment: .topTrailing
                )
                .rotation3DEffect(
                    provideAngle(proxy: proxy),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: proxy.frame(in: .global).minX > 0 ? .leading : .trailing,
                    perspective: 2.5
                )
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
        .frame(height: proxy.frame(in: .local).height)
    }
}

//MARK: - helper methods

private extension StoriesView {
    
    func provideAngle(proxy: GeometryProxy) -> Angle {
        
        let progress = proxy.frame(in: .global).minX / proxy.size.width
        
        let rotationAngle: CGFloat = 45
        let degrees = rotationAngle * progress
        
        return Angle(degrees: Double(degrees))
    }
}

private extension StoriesView {
    
    enum Constants {
        
        static let defaultBackgroundColor: String = "#ffffff"
    }
}
