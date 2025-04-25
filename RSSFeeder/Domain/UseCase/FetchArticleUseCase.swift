//
//  FetchArticleUseCase.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/25.
//  
//

import Foundation
import RxSwift

protocol FetchArticlesUseCase {
    func execute(feedID: String) -> Single<[Article]>
}

final class DefaultFetchArticlesUseCase: FetchArticlesUseCase {
    private let repository: ArticleRepository

    init(repository: ArticleRepository) {
        self.repository = repository
    }

    func execute(feedID: String) -> Single<[Article]> {
        repository.fetchArticles(for: feedID)
    }
}
