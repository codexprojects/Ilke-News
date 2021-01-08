//
//  SourcesCoordinator.swift
//  Ilke News
//
//  Created by ilke yucel on 8.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import UIKit

final class SourcesCoordinator: CoordinatorProtocol {
    private(set) var childCoordinators: [CoordinatorProtocol] = []
    private let navigationController: UINavigationController
    var parentCoordinator: HeadlinesNewsCoordinator?
    var webService: NewsWebService!
    var category: Category?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let newsListViewModel = NewsSourcesListViewModel(webService: webService)
        newsListViewModel.coordinator = self
        let sourcesViewController = SourcesViewController()
        sourcesViewController.navigationItem.title = "Kaynaklar"
        sourcesViewController.navigationController?.navigationBar.barTintColor = .orange
        sourcesViewController.viewModel = newsListViewModel
        navigationController.pushViewController(sourcesViewController, animated: true)
    }

    func presentNewsDetailsViewController(with source: Source){
        let newsDetailsCoordinator = HeadlinesNewsCoordinator(navigationController: navigationController)
        newsDetailsCoordinator.source = source
        newsDetailsCoordinator.parentCoordinator = self
        childCoordinators.append(newsDetailsCoordinator)
        newsDetailsCoordinator.start()
    }

    func childDidFinish(_ childCoordinator: CoordinatorProtocol){
        if let index = childCoordinators.firstIndex(where: { coordinator -> Bool in
            return childCoordinator === coordinator
        }) {
            childCoordinators.remove(at: index)
        }
    }

    func didFinishNewsTableViewController(){
        parentCoordinator?.childDidFinish(self)
    }

    deinit {
        debugPrint("deinit from News Coordinator")
    }
}

