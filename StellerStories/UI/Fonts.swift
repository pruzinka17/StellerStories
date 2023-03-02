//
//  Fonts.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 02.03.2023.
//

import SwiftUI

extension Font {
    
    struct Shared {
        
        static let returnArrow = Font.system(size: 26, weight: .light)
        static let userName = Font.system(size: 14, weight: .bold)
        static let displayName = Font.system(size: 14, weight: .light)
        static let followButton = Font.system(size: 10, weight: .semibold, design: .default)
        static let sectionHeader = Font.system(size: 28, weight: .black, design: .default)
        static let claps = Font.system(size: 14)
    }
}
