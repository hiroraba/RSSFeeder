//
//  AppDIContainer.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/25.
//  
//

import Foundation
import RealmSwift
import AppKit

final class AppDIContainer {

    // MARK: - Shared

    lazy var realm: Realm = {
        return try! Realm()
    }()

    lazy var rssFeedAPI: RSSFeedAPI = {
        return DefaultRSSFeedAPI()
    }()

    // MARK: - Repository

    lazy var feedRepository: FeedRepository = {
        FeedRepositoryImpl(
            realm: realm,
            rssParser: rssFeedAPI
        )
    }()

    // MARK: - UseCases

    func makeFetchFeedsUseCase() -> FetchFeedsUseCase {
        DefaultFetchFeedsUseCase(repository: feedRepository)
    }

    func makeAddFeedUseCase() -> AddFeedUseCase {
        DefaultAddFeedUseCase(repository: feedRepository)
    }
    
    func makeDeleteFeedUseCase() -> DeleteFeedUseCase {
        DefaultDeleteFeedUseCase(repository: feedRepository)
    }
    
    func makeRefreshFeedUseCase() -> RefreshFeedUseCase {
        DefaultRefreshFeedUseCase(rssFeedAPI: rssFeedAPI, feedRepository: feedRepository)
    }

    // MARK: - ViewModel

    func makeFeedListViewModel() -> FeedListViewModel {
        FeedListViewModel(
            fetchFeedsUseCase: makeFetchFeedsUseCase(),
            addFeedUseCase: makeAddFeedUseCase(),
            deleteFeedUseCase: makeDeleteFeedUseCase(),
            refreshFeedUseCase: makeRefreshFeedUseCase()
        )
    }
    
    // MARK: - ArticleRepository

    lazy var articleRepository: ArticleRepository = {
        ArticleRepositoryImpl()
    }()

    // MARK: - Article UseCases

    func makeFetchArticlesUseCase() -> FetchArticlesUseCase {
        DefaultFetchArticlesUseCase(repository: articleRepository)
    }

    // MARK: - Article ViewModel

    func makeArticleListViewModel(feedID: String) -> ArticleListViewModelType {
        ArticleListViewModel(
            feedID: feedID,
            fetchArticlesUseCase: makeFetchArticlesUseCase()
        )
    }

    // MARK: - Article ViewController

    func makeArticleListViewController(feedID: String) -> NSViewController {
        ArticleListViewController(viewModel: makeArticleListViewModel(feedID: feedID))
    }
}
