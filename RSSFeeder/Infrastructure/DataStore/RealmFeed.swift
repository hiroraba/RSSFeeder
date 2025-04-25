//
//  RealmFeed.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/24.
//  
//

import Foundation
import RealmSwift

final class RealmFeed: Object {
    @Persisted(primaryKey: true) var id: String
    @Persisted var title: String
    @Persisted var urlString: String
    @Persisted var lastUpdated: Date?
    @Persisted var articles = List<RealmArticle>()
}

extension RealmFeed {
    func toEntity() -> Feed {
        return Feed(
            id: id,
            title: title,
            url: URL(string: urlString)!,
            lastUpdated: lastUpdated
        )
    }

    static func fromEntity(_ entity: Feed) -> RealmFeed {
        let object = RealmFeed()
        object.id = entity.id
        object.title = entity.title
        object.urlString = entity.url.absoluteString
        object.lastUpdated = entity.lastUpdated
        return object
    }
}
