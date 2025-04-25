//
//  RSSFeedAPI.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/24.
//  
//

import Foundation
import RxSwift

protocol RSSFeedAPI {
    func fetchFeedArticles(from url: URL) -> Single<RSSFeedDTO>
}
