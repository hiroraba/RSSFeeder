//
//  FeedListViewModel.swift
//  RSSFeeder
//
//  Created by matsuohiroki on 2025/04/24.
//
//

import Foundation
import RxSwift
import RxCocoa
import AppKit

final class FeedListViewModel: FeedListViewModelType {

    // MARK: - Input
    let addFeedTrigger = PublishRelay<URL>()
    let deleteFeedTrigger = PublishRelay<Feed>()
    let refreshFeedTrigger = PublishRelay<Feed>()
    let refreshAllFeedsTrigger = PublishRelay<Void>()

    // MARK: - Output
    private let feedsRelay = BehaviorRelay<[Feed]>(value: [])
    private let isLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let errorRelay = PublishRelay<String?>()

    var feeds: Driver<[Feed]> {
        return feedsRelay.asDriver()
    }

    var isLoading: Driver<Bool> {
        isLoadingRelay.asDriver()
    }

    var errorMessage: Driver<String?> {
        errorRelay.asDriver(onErrorJustReturn: "Unexpected error")
    }

    // MARK: - Dependencies
    private let fetchFeedsUseCase: FetchFeedsUseCase
    private let addFeedUseCase: AddFeedUseCase
    private let deleteFeedUseCase: DeleteFeedUseCase
    private let refreshFeedUseCase: RefreshFeedUseCase
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(fetchFeedsUseCase: FetchFeedsUseCase,
         addFeedUseCase: AddFeedUseCase,
         deleteFeedUseCase: DeleteFeedUseCase,
         refreshFeedUseCase: RefreshFeedUseCase) {
        self.fetchFeedsUseCase = fetchFeedsUseCase
        self.addFeedUseCase = addFeedUseCase
        self.deleteFeedUseCase = deleteFeedUseCase
        self.refreshFeedUseCase = refreshFeedUseCase
        bind()
    }

    // MARK: - Binding
    private func bind() {
        addFeedTrigger
            .flatMapLatest { [weak self] url -> Completable in
                guard let self = self else { return .empty() }
                self.isLoadingRelay.accept(true)
                return self.addFeedUseCase.execute(url: url)
                    .do(onCompleted: { [weak self] in
                        self?.loadFeeds()
                    })
            }
            .subscribe(onError: { [weak self] error in
                self?.isLoadingRelay.accept(false)
                self?.errorRelay.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)

        deleteFeedTrigger
            .flatMapLatest { [weak self] feed -> Completable in
                guard let self = self else { return .empty() }
                return self.deleteFeedUseCase.execute(feed)
                    .do(onCompleted: { [weak self] in
                        self?.loadFeeds()
                    })
            }
            .subscribe(onError: { [weak self] error in
                self?.errorRelay.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
        
        refreshFeedTrigger
            .flatMap { [weak self] feed -> Completable in
                guard let self = self else { return .empty() }
                return self.refreshFeedUseCase.execute(feed: feed)
            }
            .subscribe(onError: { [weak self] error in
                self?.errorRelay.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)

        refreshAllFeedsTrigger
            .flatMapLatest { [weak self] _ -> Completable in
                guard let self = self else { return .empty() }
                let refreshTasks = self.feedsRelay.value.map { feed in
                    self.refreshFeedUseCase.execute(feed: feed)
                }
                return Completable.zip(refreshTasks)
            }
            .subscribe(onError: { [weak self] error in
                self?.errorRelay.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }

    func onAppear() {
        isLoadingRelay.accept(true)
        fetchFeedsUseCase.execute()
            .subscribe(onSuccess: { [weak self] feeds in
                guard let self = self else { return }
                self.feedsRelay.accept(feeds)
                self.isLoadingRelay.accept(false)
                feeds.forEach { self.refreshFeedTrigger.accept($0) }
            }, onFailure: { [weak self] error in
                self?.isLoadingRelay.accept(false)
                self?.errorRelay.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }

    private func loadFeeds() {
        isLoadingRelay.accept(true)
        fetchFeedsUseCase.execute()
            .subscribe(onSuccess: { [weak self] feeds in
                self?.feedsRelay.accept(feeds)
                self?.isLoadingRelay.accept(false)
            }, onFailure: { [weak self] error in
                self?.isLoadingRelay.accept(false)
                self?.errorRelay.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Feed IconName Extension
extension Feed {
    var iconName: String {
        let symbols = [
            "globe", "book", "flame", "sparkles", "bolt",
            "cloud.sun", "antenna.radiowaves.left.and.right",
            "paperplane", "lightbulb", "terminal"
        ]
        let hashValue = abs(self.title.hashValue)
        return symbols[hashValue % symbols.count]
    }
}

extension Feed {
    var accentColor: NSColor {
        let hue = CGFloat(abs(self.title.hashValue % 360)) / 360.0
        return NSColor(hue: hue, saturation: 0.6, brightness: 0.9, alpha: 1.0)
    }
}
