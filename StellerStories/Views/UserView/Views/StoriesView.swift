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
        
        ZStack {
            
            Color(hex: presenter.viewModel.stories.first(where: { $0.id == presenter.viewModel.presentedStoryId })?.coverBackground ?? Constants.defaultBackgroundColor)
                .animation(.default, value: presenter.viewModel.presentedStoryId)
                .ignoresSafeArea()
            
            VStack(alignment: .center) {
                
                TabView(selection: $presenter.viewModel.presentedStoryId) {
                    
                    ForEach(presenter.viewModel.stories, id: \.id) { story in
                        
                        makeStory(story: story)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
}

//MARK: - make story

private extension StoriesView {
    
    @ViewBuilder func makeStory(story: Story) -> some View {
        
        GeometryReader { proxy in
            
            VStack {
                
                AsyncImage(url: URL(string: story.coverSource)) { image in
                    
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    
                    Color(hex: story.coverBackground)
                }
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
                getAngle(proxy: proxy),
                axis: (x: 0, y: 1, z: 0),
                anchor: proxy.frame(in: .global).minX > 0 ? .leading : .trailing,
                perspective: 2.5
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        
//        GeometryReader { proxy in
//
//            let frame = proxy.frame(in: .local)
//
//            ZStack(alignment: .bottomTrailing) {
//
//                AsyncImage(url: URL(string: story.coverSource)) { image in
//
//                    image
//                        .resizable()
//                        .clipShape(RoundedRectangle(cornerRadius: 15))
//                        .frame(width: frame.width, height: frame.width * 16 / 9)
//
//                } placeholder: {
//
//                    Color(hex: story.coverBackground)
//                }
//            }
//            .overlay(
//
//                Button {
//
//                    withAnimation {
//
//                        dismissCurrentView()
//                    }
//                } label: {
//
//                    Image(systemName: "xmark")
//                        .font(.title2)
//                        .foregroundColor(.white)
//                }
//                .padding()
//
//                , alignment: .topTrailing
//            )
//            .rotation3DEffect(
//                getAngle(proxy: proxy),
//                axis: (x: 0, y: 1, z: 0),
//                anchor: proxy.frame(in: .global).minX > 0 ? .leading : .trailing,
//                perspective: 2.5
//            )
//        }
    }
}

//MARK: - helper methods

private extension StoriesView {
    
    func getAngle(proxy: GeometryProxy) -> Angle {
        
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
