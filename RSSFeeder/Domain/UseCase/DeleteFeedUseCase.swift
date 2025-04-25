//
//  DeleteFeedUseCase.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/25.
//  
//

import Foundation
import RxSwift

protocol DeleteFeedUseCase {
    func execute(_ feed: Feed) -> Completable
}

final class DefaultDeleteFeedUseCase: DeleteFeedUseCase {
    private let repository: FeedRepository

    init(repository: FeedRepository) {
        self.repository = repository
    }

    func execute(_ feed: Feed) -> Completable {
        return repository.deleteFeed(feed: feed)
    }
}
