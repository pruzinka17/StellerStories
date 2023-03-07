//
//  AddCollectionButtonStyle.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 07.03.2023.
//

import SwiftUI

struct AddCollectionButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
    
        configuration.label
            .fontWeight(.bold)
            .foregroundColor(.black)
            .font(.system(size: 12))
            .padding()
            .background {
                
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(.gray)
                    .opacity(0.1)
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            //.animation(., value: configuration.isPressed)
    }
}
