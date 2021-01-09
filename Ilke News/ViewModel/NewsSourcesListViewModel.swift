//
//  NewsSourcesListViewModel.swift
//  Ilke News
//
//  Created by ilke yucel on 7.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import Foundation

final class NewsSourcesListViewModel {

    // MARK: Constants and Variables

    var coordinator: SourcesCoordinator?
    var webService: NewsServiceProtocol!
    var category: Category?
    var query: String?

    var onUpdateNews: () -> Void = {}
    var onUpdateSearchNews: () -> Void = {}
    var onShowAlert: (String, String?) -> Void = { _, _ in }

    private var nextPage = 1
    var newsCells: [SourcesNewsCellViewModel] = []
    var isLastPage: Bool = true

    // MARK: Initializer
    init(webService: NewsServiceProtocol) {
        self.webService = webService
    }

    // MARK: News Functions
    func viewDidLoad() {
        webService.getSourcesList(
            completion: completionHandler(object: error:)
        )
    }

    func viewDidScrollToBottom() {

        print("scroll newssources")
    }

    func completionHandler(object: SourceItem?, error: HTTPError?) {
        guard error == nil else {
            onShowAlert("Network Error", error?.localizedDescription)
            return
        }

        guard let object = object, let sources = object.sources else { return }
        newsCells = sources.map({ SourcesNewsCellViewModel(sourceDetail: $0) })

        onUpdateNews()
    }

    // MARK: Coordinator Functions
    func newsDidSelect(at index: Int, sourceItem: Source) {
       // let news = newsCells[index]

        coordinator?.presentNewsDetailsViewController(with: sourceItem)
    }

    func viewDidDisappear() {
        coordinator?.didFinishNewsTableViewController()
    }

    deinit {
        debugPrint("deinit from News ViewModel")
    }
}
