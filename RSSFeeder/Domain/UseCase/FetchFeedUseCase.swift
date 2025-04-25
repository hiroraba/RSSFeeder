//
//  FetchFeedUseCase.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/24.
//  
//

import Foundation
import RxSwift

protocol FetchFeedsUseCase {
    func execute() -> Single<[Feed]>
}

final class DefaultFetchFeedsUseCase: FetchFeedsUseCase {
    private let repository: FeedRepository

    init(repository: FeedRepository) {
        self.repository = repository
    }

    func execute() -> Single<[Feed]> {
        repository.fetchFeeds()
    }
}
