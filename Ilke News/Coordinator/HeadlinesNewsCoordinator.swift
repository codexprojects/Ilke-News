//
//  NewsCoordinator.swift
//  Ilke News
//
//  Created by ilke yucel on 7.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import UIKit

final class HeadlinesNewsCoordinator: CoordinatorProtocol {
    private(set) var childCoordinators: [CoordinatorProtocol] = []
    private let navigationController: UINavigationController
    var parentCoordinator: SourcesCoordinator?
    var webService = NewsWebService()
    var source: Source!

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let newsListViewModel = NewsListViewModel(webService: webService, source: source)
        newsListViewModel.coordinator = self
        let headlinesViewController = HeadlinesViewController()
        headlinesViewController.navigationItem.title = source.name
        headlinesViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: nil)
        headlinesViewController.viewModel = newsListViewModel
        navigationController.pushViewController(headlinesViewController, animated: true)
    }

    func presentNewsDetailsViewController(with url: String) {
        // If necessary navigate to detail screen logic will add. (todo)
    }

    func childDidFinish(_ childCoordinator: CoordinatorProtocol) {
        if let index = childCoordinators.firstIndex(where: { coordinator -> Bool in
            return childCoordinator === coordinator
        }) {
            childCoordinators.remove(at: index)
        }
    }

    func didFinishNewsTableViewController() {
        parentCoordinator?.childDidFinish(self)
    }

    deinit {
        debugPrint("deinit from News Coordinator")
    }
}
