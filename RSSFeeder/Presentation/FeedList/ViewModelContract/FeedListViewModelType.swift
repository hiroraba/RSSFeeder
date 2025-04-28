//
//  FeedListViewModelType.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/24.
//  
//

import Foundation
import RxSwift
import RxCocoa

protocol FeedListViewModelType {
    // Inputs
    var addFeedTrigger: PublishRelay<URL> { get }
    var deleteFeedTrigger: PublishRelay<Feed> { get }
    var refreshFeedTrigger: PublishRelay<Feed> { get }
    var refreshAllFeedsTrigger: PublishRelay<Void> { get }

    // Outputs
    var feeds: Driver<[Feed]> { get }
    var isLoading: Driver<Bool> { get }
    var errorMessage: Driver<String?> { get }

    // ライフサイクルイベントなど
    func onAppear()
}
