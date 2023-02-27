//
//  StoryDTO.swift
//  StellerStories
//
//  Created by Miroslav Bořek on 16.02.2023.
//

import Foundation

struct StoryDTO: Codable {
    
    let id: String
    
    let coverSource: String
    let coverBackground: String
    
    let title: String?
    
    let commentCount: Int
    
    let aspectRatio: String
    
    let likes: LikeDTO
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.coverSource = try container.decode(String.self, forKey: .coverSource)
        self.coverBackground = try container.decode(String.self, forKey: .coverBackground)
        self.title = try container.decode(String.self, forKey: .title)
        self.commentCount = try container.decode(Int.self, forKey: .commentCount)
        self.aspectRatio = try container.decode(String.self, forKey: .aspectRatio)
        self.likes = try container.decode(LikeDTO.self, forKey: .likes)
    }
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        
        case coverSource = "cover_src"
        case coverBackground = "cover_bg"
        
        case title = "title"
        
        case commentCount = "comment_count"
        
        case aspectRatio = "aspect_ratio"
        
        case likes = "likes"
    }
    
    struct LikeDTO: Codable {
        
        let count: Int
        
        init(from decoder: Decoder) throws {
            
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.count = try container.decode(Int.self, forKey: .count)
        }
        
        enum CodingKeys: String, CodingKey {
            
            case count = "count"
        }
    }
}
