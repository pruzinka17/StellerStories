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
    
    init(
        context: StoriesContext,
        eventHadler: StoriesEventHandler
    ) {
        
        self.presenter = StoriesPresenter(
            context: context,
            eventHandler: eventHadler
        )
    }
    
    var body: some View {
        
        GeometryReader { proxy in
            
            ZStack {
                
                Color(hex: presenter.viewModel.viewBackgroundColor)
                    .animation(.default, value: presenter.viewModel.presentedStoryId)
                    .ignoresSafeArea()
                    
                TabView(selection: $presenter.viewModel.presentedStoryId) {
                        
                    ForEach(presenter.viewModel.stories, id: \.id) { story in
                        
                        makeStory(story: story, proxy: proxy)
                            .tag(story.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }.onAppear {
            
            presenter.present()
        }
    }
}

//MARK: - make story

private extension StoriesView {
    
    @ViewBuilder func makeStory(story: Story, proxy: GeometryProxy) -> some View {
            
        GeometryReader { proxy in
                
            AsyncImage(url: story.coverSource) { image in
                
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                
                Color(hex: story.coverBackground)
            }
            .overlay(

                Button {

                    dismissCurrentView()
                    presenter.handleClose()
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
            .clipShape(RoundedRectangle(cornerRadius: Constants.storyCornerRadius))
        }
    }
}

// MARK: - helper methods

private extension StoriesView {
    
    func provideAngle(proxy: GeometryProxy) -> Angle {
        
        let progress = proxy.frame(in: .global).minX / proxy.size.width
        
        let rotationAngle: CGFloat = 45
        let degrees = rotationAngle * progress
        
        return Angle(degrees: Double(degrees))
    }
}

// MARK: - Constants

private extension StoriesView {
    
    enum Constants {
        
        static let storyCornerRadius: CGFloat = 15
    }
}
