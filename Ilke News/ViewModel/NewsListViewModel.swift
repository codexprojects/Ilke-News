//
//  NewsListViewModel.swift
//  Ilke News
//
//  Created by ilke yucel on 7.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import Foundation

final class NewsListViewModel {

    // MARK: Constants and Variables

    var coordinator: HeadlinesNewsCoordinator?
    var webService: NewsServiceProtocol!

    var onUpdateNews: () -> Void = {}
    var onUpdateSearchNews: () -> Void = {}
    var onShowAlert: (String, String?) -> Void = { _, _ in }

    private var nextPage = 1
    var newsCells: [HeadlinesNewsCellViewModel] = []
    var isLastPage: Bool = true

    var source: Source!

    // MARK: Initializer

    init(webService: NewsServiceProtocol, source: Source) {
        self.webService = webService
        self.source = source
    }

    // MARK: News Functions

    func viewDidLoad() {

        webService.getHeadlinesList(
            source: source.id, completion: firstPageCompletionHandler(object: error:)
        )
    }

    func viewDidScrollToBottom() {
      print("scroll list")
    }

    func firstPageCompletionHandler(object: HeadlineItem?, error: HTTPError?) {
        guard error == nil else {
            onShowAlert("Network Error", error?.localizedDescription)
            return
        }

        guard let object = object, let articles = object.articles else { return }
        newsCells = articles.map({ HeadlinesNewsCellViewModel(article: $0) })

        onUpdateNews()
    }

    func otherPagesCompletionHandler(object: HeadlineItem?, error: HTTPError?) {
        guard error == nil else {
            onShowAlert("Network Error", error?.localizedDescription)
            return
        }

        guard let object = object, let articles = object.articles else { return }
        newsCells += articles.map({ HeadlinesNewsCellViewModel(article: $0) })

        onUpdateNews()
    }

    // MARK: Coordinator Functions

    func newsDidSelect(at index: Int) {
        let news = newsCells[index]
        coordinator?.presentNewsDetailsViewController(with: news.url)
    }

    func viewDidDisappear() {
        coordinator?.didFinishNewsTableViewController()
    }

    deinit {
        debugPrint("deinit from News ViewModel")
    }
}
