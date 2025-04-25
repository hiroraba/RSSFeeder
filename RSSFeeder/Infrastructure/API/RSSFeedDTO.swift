//
//  RSSFeedDTO.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/25.
//  
//

import Foundation

struct RSSFeedDTO {
    let title: String
    let lastBuildDate: Date?
    let articles: [RSSArticleDTO]
}
