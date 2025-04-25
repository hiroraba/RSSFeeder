//
//  ArticleRepositoryImpl.swift
//  RSSFeeder
//  
//  Created by matsuohiroki on 2025/04/25.
//  
//

import Foundation
import RxSwift
import RealmSwift

final class ArticleRepositoryImpl: ArticleRepository {

    func fetchArticles(for feedID: String) -> Single<[Article]> {
        return Single.create { single in
            do {
                let realm = try Realm()
                let results = realm.objects(RealmArticle.self)
                    .filter("feedID == %@", feedID)
                    .sorted(byKeyPath: "publishedAt", ascending: false)

                let articles = results.map { $0.toEntity() }
                single(.success(Array(articles)))
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
}
