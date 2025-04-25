//
//  FeedRepositoryImpl.swift
//  RSSFeeder
//
//  Created by matsuohiroki on 2025/04/24.
//
//

import Foundation
import RxSwift
import RealmSwift

final class FeedRepositoryImpl: FeedRepository {
    
    private let realm: Realm
    private let rssParser: RSSFeedAPI

    init(realm: Realm = try! Realm(), rssParser: RSSFeedAPI) {
        self.realm = realm
        self.rssParser = rssParser
    }

    func fetchFeeds() -> Single<[Feed]> {
        return Single<[Feed]>.create { observer in
            let realm = try! Realm()
            let results = realm.objects(RealmFeed.self)
            let feeds = results.map { $0.toEntity() }
            observer(.success(Array(feeds)))
            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
        .observe(on: MainScheduler.instance)
    }

    func addFeed(url: URL) -> Completable {
        return rssParser.fetchFeedArticles(from: url)
            .flatMapCompletable { dtoArticles in
                Completable.create { observer in
                    let realm = try! Realm()
                    do {
                        try realm.write {
                            let feedID = UUID().uuidString
                            let feed = RealmFeed()
                            feed.id = feedID
                            feed.title = dtoArticles.first?.feedTitle ?? "Unknown Feed"
                            feed.urlString = url.absoluteString
                            feed.lastUpdated = Date()

                            let articles = dtoArticles.map { dto -> RealmArticle in
                                let a = RealmArticle()
                                a.id = UUID().uuidString
                                a.feedID = feedID
                                a.title = dto.title
                                a.link = dto.link.absoluteString
                                a.publishedAt = dto.publishedAt
                                a.summary = dto.summary
                                a.isFavorite = false
                                return a
                            }
                            feed.articles.append(objectsIn: articles)
                            realm.add(feed)
                        }
                        observer(.completed)
                    } catch {
                        observer(.error(error))
                    }
                    return Disposables.create()
                }
            }
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }

    func deleteFeed(feed: Feed) -> Completable {
        return Completable.create { observer in
            do {
                let realm = try Realm()
                if let realmFeed = realm.object(ofType: RealmFeed.self, forPrimaryKey: feed.id) {
                    try realm.write {
                        realm.delete(realmFeed.articles)
                        realm.delete(realmFeed)
                    }
                }
                observer(.completed)
            } catch {
                observer(.error(error))
            }
            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }

    func resetRealm() -> Completable {
        return Completable.create { observer in
            do {
                let realm = try Realm()
                try realm.write {
                    realm.deleteAll()
                }
                observer(.completed)
            } catch {
                observer(.error(error))
            }
            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }
    
    func updateArticles(for feed: Feed, with articles: [RSSArticleDTO]) -> Completable {
        return Completable.create { observer in
            do {
                let realm = try Realm()
                guard let realmFeed = realm.object(ofType: RealmFeed.self, forPrimaryKey: feed.id) else {
                    observer(.completed)
                    return Disposables.create()
                }

                try realm.write {
                    realm.delete(realmFeed.articles)

                    let newArticles = articles.map { dto -> RealmArticle in
                        let article = RealmArticle()
                        article.id = UUID().uuidString
                        article.feedID = feed.id
                        article.title = dto.title
                        article.link = dto.link.absoluteString
                        article.publishedAt = dto.publishedAt
                        article.summary = dto.summary
                        article.isFavorite = false
                        return article
                    }

                    realmFeed.articles.append(objectsIn: newArticles)
                    realmFeed.lastUpdated = Date()
                }

                observer(.completed)
            } catch {
                observer(.error(error))
            }

            return Disposables.create()
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    }
}
