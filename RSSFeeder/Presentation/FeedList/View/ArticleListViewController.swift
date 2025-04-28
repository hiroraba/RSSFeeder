//
//  ArticleListViewController.swift
//  RSSFeeder
//
//  Created by matsuohiroki on 2025/04/25.
//
//

import Cocoa
import RxSwift
import RxCocoa

final class ArticleListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    private let tableView = NSTableView()
    private let scrollView = NSScrollView()
    private let activityIndicator = NSProgressIndicator()

    private var viewModel: ArticleListViewModelType
    var onBack: (() -> Void)?
    /// Closure called when an article is selected.
    var onArticleSelected: ((Article) -> Void)?
    private let disposeBag = DisposeBag()
    private var articles: [Article] = []

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    init(viewModel: ArticleListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        bindViewModel()
        viewModel.onAppear()
    }

    private func setupUI() {
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("ArticleColumn"))
        column.title = "Article Title"
        tableView.addTableColumn(column)
        tableView.headerView = nil
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true

        // Enable automatic row heights for the table view
        tableView.usesAutomaticRowHeights = true

        activityIndicator.style = .spinning
        activityIndicator.controlSize = .small
        activityIndicator.isDisplayedWhenStopped = false

        [scrollView, activityIndicator].forEach { view.addSubview($0) }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func bindViewModel() {
        viewModel.articles
            .drive(onNext: { [weak self] articles in
                self?.articles = articles
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        viewModel.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimation(nil)
                } else {
                    self?.activityIndicator.stopAnimation(nil)
                }
            })
            .disposed(by: disposeBag)

        viewModel.errorMessage
            .drive(onNext: { [weak self] message in
                guard let msg = message else { return }
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = msg
                alert.runModal()
            })
            .disposed(by: disposeBag)
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return articles.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let article = articles[row]
        let identifier = NSUserInterfaceItemIdentifier("ArticleCell")
        if let cell = tableView.makeView(withIdentifier: identifier, owner: self) {
            (cell.viewWithTag(1) as? NSTextField)?.stringValue = article.title
            (cell.viewWithTag(2) as? NSTextField)?.stringValue = "\(article.title)  •  \(dateFormatter.string(from: article.publishedAt))"
            (cell.viewWithTag(3) as? NSTextField)?.stringValue = article.summary ?? ""
            return cell
        } else {
            return makeArticleCell(for: article)
        }
    }

    private func makeArticleCell(for article: Article) -> NSView {
        let identifier = NSUserInterfaceItemIdentifier("ArticleCell")
        let container = NSView()
        container.identifier = identifier

        let titleLabel = NSTextField(labelWithString: article.title)
        titleLabel.font = NSFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.maximumNumberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.tag = 1

        let metaLabel = NSTextField(labelWithString: "\(article.title)  •  \(dateFormatter.string(from: article.publishedAt))")
        metaLabel.font = NSFont.systemFont(ofSize: 11)
        metaLabel.textColor = .secondaryLabelColor
        metaLabel.translatesAutoresizingMaskIntoConstraints = false
        metaLabel.tag = 2

        let summaryLabel = NSTextField(labelWithString: article.summary ?? "")
        summaryLabel.font = NSFont.systemFont(ofSize: 13)
        summaryLabel.textColor = .tertiaryLabelColor
        summaryLabel.lineBreakMode = .byWordWrapping
        summaryLabel.maximumNumberOfLines = 3
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.tag = 3

        let separator = NSBox()
        separator.boxType = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false

        [titleLabel, metaLabel, summaryLabel, separator].forEach { container.addSubview($0) }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            metaLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            metaLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            metaLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            summaryLabel.topAnchor.constraint(equalTo: metaLabel.bottomAnchor, constant: 4),
            summaryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            summaryLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            summaryLabel.bottomAnchor.constraint(lessThanOrEqualTo: separator.topAnchor, constant: -10),

            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])

        return container
    }
    
    func rebindViewModel(_ newViewModel: ArticleListViewModelType) {
        // 明示的に初期化し直す
        self.viewModel = newViewModel
        bindViewModel()
        viewModel.onAppear()
    }

    // MARK: - NSTableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {
        let selectedRow = tableView.selectedRow
        guard selectedRow >= 0, selectedRow < articles.count else { return }
        onArticleSelected?(articles[selectedRow])
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        // Provide enough height for title, date, and summary labels
        return 72
    }
}
