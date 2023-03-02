//
//  Story.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 18.02.2023.
//

import Foundation

struct Story {
    
    let id: String
    
    let title: String?
    
    let coverSource: URL
    let coverBackground: String
    
    let commentCount: Int
    let likes: Int
    
    let aspectRatio: AspectRatio
}

enum AspectRatio: String {
    
    case nineToSixteen = "9:16"
    case twoToThree = "2:3"
}
