//
//  ViewController.swift
//  DoubleTableView
//
//  Created by Michalis Karagiorgos L on 20/9/22.
//

import UIKit

struct TopTableUIModel {
    let rows: [Row]
    
    enum Section {
        case top
    }
    
    struct Row: Hashable {
        let number: Int
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let topTableView: UITableView = UITableView()
    let bottomTableView: UITableView = UITableView()
    let scrollView: UIScrollView = UIScrollView()
    var scrollViewHeightConstraint: NSLayoutConstraint?
    var topTableViewHeightConstraint: NSLayoutConstraint?
    var bottomTableViewHeightConstraint: NSLayoutConstraint?
    
    typealias Datasource = UITableViewDiffableDataSource<TopTableUIModel.Section, TopTableUIModel.Row>
    typealias DatasourceSnapshot = NSDiffableDataSourceSnapshot<TopTableUIModel.Section, TopTableUIModel.Row>
    private lazy var datasource: Datasource = configureTableViewDatasource()
    private var snapshot = DatasourceSnapshot()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(topTableView)
        scrollView.addSubview(bottomTableView)
        topTableView.tag = 0
        bottomTableView.tag = 1
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        topTableView.translatesAutoresizingMaskIntoConstraints = false
        bottomTableView.translatesAutoresizingMaskIntoConstraints = false
        topTableView.backgroundColor = .red
        bottomTableView.backgroundColor = .blue
        scrollView.backgroundColor = .yellow
        scrollView.isScrollEnabled = true
        topTableView.isScrollEnabled = false
        topTableView.showsVerticalScrollIndicator = false
        bottomTableView.isScrollEnabled = false
        bottomTableView.showsVerticalScrollIndicator = false
        topTableView.dataSource = datasource
        bottomTableView.dataSource = self
        topTableView.delegate = self
        bottomTableView.delegate = self
        let scrollViewHeightConstraint = scrollView.heightAnchor.constraint(equalToConstant: 1000)
        scrollViewHeightConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollViewHeightConstraint
        ])
        self.scrollViewHeightConstraint = scrollViewHeightConstraint
        let topTableViewHeightConstraint = topTableView.heightAnchor.constraint(equalToConstant: 500)
        topTableViewHeightConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            topTableView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            topTableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            topTableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            topTableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            topTableViewHeightConstraint
        ])
        self.topTableViewHeightConstraint = topTableViewHeightConstraint
        let bottomTableViewHeightConstraint = bottomTableView.heightAnchor.constraint(equalToConstant: 500)
        bottomTableViewHeightConstraint.priority = .defaultLow
        NSLayoutConstraint.activate([
            bottomTableView.topAnchor.constraint(equalTo: topTableView.bottomAnchor),
            bottomTableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            bottomTableView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            bottomTableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            bottomTableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            bottomTableViewHeightConstraint
        ])
        self.bottomTableViewHeightConstraint = bottomTableViewHeightConstraint
        updateTopTableView(range: (0...20))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.bottomTableView.reloadData()
            self?.updateTopTableView(range: (0...5))
            self?.view.setNeedsLayout()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("top: \(topTableView.contentSize.height)")
        print("bottom: \(bottomTableView.contentSize.height)")
        topTableViewHeightConstraint?.constant = topTableView.contentSize.height
        bottomTableViewHeightConstraint?.constant = bottomTableView.contentSize.height
       
        //place some bottom peeding as you want
        let bottomPedding:CGFloat = 30
        scrollView.contentSize = CGSize.init(
            width: scrollView.contentSize.width,
            height: topTableView.contentSize.height + bottomTableView.contentSize.height + bottomPedding
        )
        print("scroll: \(scrollView.contentSize.height)")
        scrollViewHeightConstraint?.constant = scrollView.contentSize.height
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("numberOfSections tag: \(tableView.tag)")
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection tag: \(tableView.tag)")
        return 20
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellForRowAt tag: \(tableView.tag)")
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.row)"
        cell.contentView.backgroundColor = .blue
        return cell
    }
    
    private func configureTableViewDatasource() -> Datasource {
        Datasource(tableView: topTableView) { tableView, indexPath, row in
            let cell = UITableViewCell()
            cell.contentView.backgroundColor = .green
            cell.textLabel?.text = "\(row.number)"
            return cell
        }
    }
    
    func updateTopTableView(range: ClosedRange<Int>) {
        snapshot = DatasourceSnapshot()
        let uiModel = TopTableUIModel(
            rows: range.map(TopTableUIModel.Row.init)
        )
        snapshot.appendSections([TopTableUIModel.Section.top])
        snapshot.appendItems(uiModel.rows, toSection: TopTableUIModel.Section.top)
        UIView.performWithoutAnimation {
            datasource.apply(snapshot, animatingDifferences: true)
        }
    }
}

