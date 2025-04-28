//
//  FeedListViewController.swift
//
//
//  Created by matsuohiroki on 2025/04/24.
//
//

import Cocoa
import RxSwift
import RxCocoa

final class FeedListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var onFeedSelected: ((Feed) -> Void)?

    private let tableView = NSTableView()
    private let scrollView = NSScrollView()
    private let addButton = NSButton(title: "＋", target: nil, action: nil)
    private let activityIndicator = NSProgressIndicator()

    private let viewModel: FeedListViewModelType
    private let disposeBag = DisposeBag()
    private var feedItems: [Feed] = []
    
    private var hasRefreshedOnce = false

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    init(viewModel: FeedListViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        let container = AppDIContainer()
        self.viewModel = container.makeFeedListViewModel()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        bindViewModel()
        viewModel.onAppear()
        
    }

    private func setupUI() {
        // TableView setup
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("FeedColumn"))
        column.title = "Feed Title"
        tableView.addTableColumn(column)
        tableView.headerView = nil
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true

        // ActivityIndicator
        activityIndicator.style = .spinning
        activityIndicator.controlSize = .small
        activityIndicator.isDisplayedWhenStopped = false

        // Set button style for visibility
        addButton.bezelStyle = .rounded

        // Layout
        [scrollView, addButton, activityIndicator].forEach { view.addSubview($0) }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        // フィード一覧の表示
        viewModel.feeds
            .drive(onNext: { [weak self] feeds in
                self?.feedItems = feeds
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        // 読み込みスピナー
        viewModel.isLoading
            .drive(onNext: { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.startAnimation(nil)
                } else {
                    self?.activityIndicator.stopAnimation(nil)
                }
            })
            .disposed(by: disposeBag)

        // エラー表示
        viewModel.errorMessage
            .drive(onNext: { [weak self] message in
                guard let msg = message else { return }
                let alert = NSAlert()
                alert.messageText = "Error"
                alert.informativeText = msg
                alert.runModal()
            })
            .disposed(by: disposeBag)

        // フィード追加
        addButton.rx.tap
            .subscribe(onNext: { [weak self] in self?.showAddFeedDialog() })
            .disposed(by: disposeBag)
    }

    private func showAddFeedDialog() {
        let alert = NSAlert()
        alert.messageText = "Add RSS Feed URL"
        alert.informativeText = "Enter a valid RSS feed URL"
        alert.addButton(withTitle: "Add")
        alert.addButton(withTitle: "Cancel")

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        alert.accessoryView = input

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: input.stringValue) {
                viewModel.addFeedTrigger.accept(url)
            }
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return feedItems.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return makeFeedCell(for: feedItems[row])
    }
    
    private func makeFeedCell(for feed: Feed) -> NSView {
        let identifier = NSUserInterfaceItemIdentifier("FeedCell")

        let cell = NSTableCellView()
        cell.identifier = identifier

        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let iconView = NSImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        iconView.contentTintColor = .labelColor

        let titleLabel = NSTextField(labelWithString: "")
        titleLabel.font = NSFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let dateLabel = NSTextField(labelWithString: "")
        dateLabel.font = NSFont.systemFont(ofSize: 11)
        dateLabel.textColor = .secondaryLabelColor
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        let separator = NSBox()
        separator.boxType = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false

        // --- 差し色バーの追加 ---
        let colorBar = NSView()
        colorBar.wantsLayer = true
        colorBar.layer?.cornerRadius = 2
        colorBar.translatesAutoresizingMaskIntoConstraints = false
        colorBar.layer?.backgroundColor = feed.accentColor.cgColor
        // --- ここまで追加 ---

        // 差し色バーを一番最初に追加
        container.addSubview(colorBar)
        container.addSubview(iconView)
        container.addSubview(titleLabel)
        container.addSubview(dateLabel)
        container.addSubview(separator)
        cell.addSubview(container)

        NSLayoutConstraint.activate([
            // 差し色バーの制約
            colorBar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            colorBar.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            colorBar.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            colorBar.widthAnchor.constraint(equalToConstant: 4),

            iconView.leadingAnchor.constraint(equalTo: colorBar.trailingAnchor, constant: 8),
            iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            separator.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4)
        ])

        titleLabel.stringValue = feed.title

        iconView.image = NSImage(systemSymbolName: feed.iconName, accessibilityDescription: nil)

        if let latest = feed.lastUpdated {
            dateLabel.stringValue = "Last updated: \(dateFormatter.string(from: latest))"
        } else {
            dateLabel.stringValue = "No articles"
        }

        return cell
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        let selectedFeed = feedItems[row]
        onFeedSelected?(selectedFeed)
        return true
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        // Provide enough height for title, date, and summary labels
        return 60
    }
    
    // MARK: - Keyboard Handling
    override func keyDown(with event: NSEvent) {
        
        if event.modifierFlags.contains(.command), event.charactersIgnoringModifiers?.lowercased() == "r" {
            viewModel.refreshAllFeedsTrigger.accept(())
            return
        }
        
        guard event.keyCode == 51 else { // 51 = delete/backspace key
            super.keyDown(with: event)
            return
        }

        let selectedRow = tableView.selectedRow
        guard selectedRow >= 0 && selectedRow < feedItems.count else { return }

        let feedToDelete = feedItems[selectedRow]
        let alert = NSAlert()
        alert.messageText = "Delete Feed?"
        alert.informativeText = "Are you sure you want to delete '\(feedToDelete.title)'?"
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .warning

        if alert.runModal() == .alertFirstButtonReturn {
            viewModel.deleteFeedTrigger.accept(feedToDelete)
        }
    }

}
