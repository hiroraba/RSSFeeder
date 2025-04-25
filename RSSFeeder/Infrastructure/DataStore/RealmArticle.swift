//
//  RealmArticle.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/24.
//  
//

import Foundation
import RealmSwift

final class RealmArticle: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var feedID: String
    @Persisted var title: String
    @Persisted var link: String
    @Persisted var publishedAt: Date
    @Persisted var summary: String?
    @Persisted var isFavorite: Bool
}

extension RealmArticle {
    func toEntity() -> Article {
        return Article(
            id: id,
            feedID: feedID,
            title: title,
            link: URL(string: link)!,
            publishedAt: publishedAt,
            summary: summary,
            isFavorite: isFavorite
        )
    }
}
