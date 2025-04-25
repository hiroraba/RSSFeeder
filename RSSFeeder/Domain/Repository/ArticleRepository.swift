//
//  ArticleRepository.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/24.
//  
//

import Foundation
import RxSwift

protocol ArticleRepository {
    func fetchArticles(for feedID: String) -> Single<[Article]>
}
