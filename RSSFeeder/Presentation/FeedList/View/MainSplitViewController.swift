//
//  MainSplitViewController.swift
//  RSSFeeder
//
//  Created by matsuohiroki on 2025/04/25.
//
//

import Cocoa

final class MainSplitViewController: NSSplitViewController {

    private let feedViewController: FeedListViewController
    private let articleViewController: ArticleListViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ MainSplitViewController loaded")
        setupSplitView()
        bindSelection()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        splitView.setPosition(180, ofDividerAt: 0)
    }
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        let container = AppDIContainer()
        let feedVM = container.makeFeedListViewModel()
        let articleVM = container.makeArticleListViewModel(feedID: "")

        self.feedViewController = FeedListViewController(viewModel: feedVM)
        self.articleViewController = ArticleListViewController(viewModel: articleVM)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSplitView() {
        let feedItem = NSSplitViewItem(viewController: feedViewController)
        
        let articleItem = NSSplitViewItem(viewController: articleViewController)
        self.addSplitViewItem(feedItem)
        self.addSplitViewItem(articleItem)
        
        feedItem.minimumThickness = 140
        feedItem.canCollapse = false
    }

    private func bindSelection() {
        feedViewController.onFeedSelected = { [weak self] feed in
            let articleListVM = AppDIContainer().makeArticleListViewModel(feedID: feed.id)
            self?.articleViewController.rebindViewModel(articleListVM)

            // 選択された記事を受け取ったときの遷移
            self?.articleViewController.onArticleSelected = { article in
                NSWorkspace.shared.open(article.link)
            }
        }
    }
}
