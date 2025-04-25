//
//  Article.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/24.
//  
//

import Foundation

struct Article: Equatable {
    let id: String
    let feedID: String
    let title: String
    let link: URL
    let publishedAt: Date
    let summary: String?
    let isFavorite: Bool
}
