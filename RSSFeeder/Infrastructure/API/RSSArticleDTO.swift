//
//  RSSArticleDTO.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/24.
//  
//

import Foundation

struct RSSArticleDTO {
    let title: String
    let link: URL
    let publishedAt: Date
    let summary: String?
}
