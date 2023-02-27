//
//  StoryView.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 23.02.2023.
//

import SwiftUI

struct StoryView: View {
    
    let story: UserViewModel.Story
    let onTap: () -> Void
    
    var body: some View {
        
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
            
            onTap()
        }
    }
}
