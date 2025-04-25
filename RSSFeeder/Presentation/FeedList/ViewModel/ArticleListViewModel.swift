//
//  ArticleListViewModel.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/25.
//  
//

import Foundation
import RxSwift
import RxCocoa

final class ArticleListViewModel: ArticleListViewModelType {

    private let fetchArticlesUseCase: FetchArticlesUseCase
    private let feedID: String
    private let disposeBag = DisposeBag()

    private let articlesRelay = BehaviorRelay<[Article]>(value: [])
    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String?>()

    var articles: Driver<[Article]> {
        articlesRelay.asDriver()
    }

    var isLoading: Driver<Bool> {
        loadingRelay.asDriver()
    }

    var errorMessage: Driver<String?> {
        errorRelay.asDriver(onErrorJustReturn: "Unknown error")
    }

    init(feedID: String, fetchArticlesUseCase: FetchArticlesUseCase) {
        self.feedID = feedID
        self.fetchArticlesUseCase = fetchArticlesUseCase
    }

    func onAppear() {
        loadingRelay.accept(true)
        fetchArticlesUseCase.execute(feedID: feedID)
            .subscribe(onSuccess: { [weak self] articles in
                self?.articlesRelay.accept(articles)
                self?.loadingRelay.accept(false)
            }, onFailure: { [weak self] error in
                self?.loadingRelay.accept(false)
                self?.errorRelay.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
