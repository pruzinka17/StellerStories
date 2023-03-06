//
//  OffsetPreferenceKey.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 06.03.2023.
//

import SwiftUI

struct OffsetPreferenceKey: PreferenceKey {
    
    static var defaultValue: CGFloat { .zero }
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        
        value = nextValue()
    }
}
