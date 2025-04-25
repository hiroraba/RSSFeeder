//
//  AddFeedUseCase.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/24.
//  
//

import Foundation
import RxSwift

protocol AddFeedUseCase {
    func execute(url: URL) -> Completable
}

final class DefaultAddFeedUseCase: AddFeedUseCase {
    private let repository: FeedRepository

    init(repository: FeedRepository) {
        self.repository = repository
    }

    func execute(url: URL) -> Completable {
        return repository.addFeed(url: url)
    }
}
