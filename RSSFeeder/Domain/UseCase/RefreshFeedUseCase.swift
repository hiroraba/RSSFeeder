//
//  RefreshFeedUseCase.swift
//  RSSFeeder
//
//  Created by matsuohiroki on 2025/04/25.
//
//

import Foundation
import RxSwift

protocol RefreshFeedUseCase {
    func execute(feed: Feed) -> Completable
}


final class DefaultRefreshFeedUseCase: RefreshFeedUseCase {
    private let rssFeedAPI: RSSFeedAPI
    private let feedRepository: FeedRepository

    init(rssFeedAPI: RSSFeedAPI, feedRepository: FeedRepository) {
        self.rssFeedAPI = rssFeedAPI
        self.feedRepository = feedRepository
    }

    func execute(feed: Feed) -> Completable {
        return rssFeedAPI.fetchFeedArticles(from: feed.url)
            .flatMapCompletable { [weak self] articles in
                self?.feedRepository.updateArticles(for: feed, with: articles) ?? .empty()
            }
    }
}
