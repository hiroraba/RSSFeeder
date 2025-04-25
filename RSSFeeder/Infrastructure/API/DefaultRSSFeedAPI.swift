//
//  DefaultRSSFeedAPI.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/24.
//  
//

import Foundation
import FeedKit
import RxSwift

final class DefaultRSSFeedAPI: RSSFeedAPI {
    func fetchFeedArticles(from url: URL) -> Single<[RSSArticleDTO]> {
        return Single.create { single in
            let parser = FeedParser(URL: url)

            parser.parseAsync(queue: DispatchQueue.global(qos: .background)) { result in
                switch result {
                case .success(let feed):
                    guard case let .rss(rssFeed) = feed else {
                        single(.failure(RSSParseError.unsupportedFormat))
                        return
                    }
                    let items = rssFeed.items?.compactMap { item -> RSSArticleDTO? in
                        guard
                            let title = item.title,
                            let linkStr = item.link,
                            let link = URL(string: linkStr),
                            let pubDate = item.pubDate
                        else {
                            return nil
                        }

                        return RSSArticleDTO(
                            title: title,
                            link: link,
                            publishedAt: pubDate,
                            summary: item.description,
                            feedTitle: rssFeed.title
                        )
                    } ?? []

                    single(.success(items))

                case .failure(let error):
                    single(.failure(error))
                }
            }

            return Disposables.create()
        }
    }
}

enum RSSParseError: Error {
    case unsupportedFormat
}
