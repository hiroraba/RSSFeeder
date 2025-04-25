//
//  FeedRepository.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/24.
//  
//

import Foundation
import RxSwift

protocol FeedRepository {
    func fetchFeeds() -> Single<[Feed]>
    func addFeed(url: URL) -> Completable
    func deleteFeed(feed: Feed) -> Completable
    func updateArticles(for feed: Feed, with articles: [RSSArticleDTO]) -> Completable
}
