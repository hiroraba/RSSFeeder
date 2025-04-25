//
//  ArticleListViewModelType.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/25.
//  
//

import RxSwift
import RxCocoa

protocol ArticleListViewModelType {
    var articles: Driver<[Article]> { get }
    var isLoading: Driver<Bool> { get }
    var errorMessage: Driver<String?> { get }

    func onAppear()
}
