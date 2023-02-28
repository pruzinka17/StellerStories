//
//  StoriesView.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 23.02.2023.
//

import SwiftUI

struct StoriesView: View {
    
    @Binding var viewModel: UserViewModel
    
    var body: some View {
        
        TabView(selection: $viewModel.presentedStoryId) {
            
            ForEach(viewModel.stories, id: \.id) { story in
                
                makeStory(story: story)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    @ViewBuilder func makeStory(story: UserViewModel.Story) -> some View {
        
        GeometryReader { proxy in
            
            ZStack(alignment: .bottomTrailing) {
                
                Color(hex: story.coverBackground)
                    .ignoresSafeArea()
                            
                AsyncImage(url: URL(string: story.coverSource)) { image in
                    
                    image.resizable()
                } placeholder: {
                    
                    Color(hex: story.coverBackground)
                }
            }
            .overlay(

                Button {
                    
                    withAnimation {
                        
                        viewModel.isPresentingStories = false
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
        }
    }
    
    func getAngle(proxy: GeometryProxy) -> Angle {
        
        let progress = proxy.frame(in: .global).minX / proxy.size.width
        
        let rotationAngle: CGFloat = 45
        let degrees = rotationAngle * progress
        
        return Angle(degrees: Double(degrees))
    }
}
