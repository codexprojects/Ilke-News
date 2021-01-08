//
//  AppCoordinator.swift
//  Ilke News
//
//  Created by ilke yucel on 7.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import Foundation
import UIKit

protocol CoordinatorProtocol: class{
    var childCoordinators: [CoordinatorProtocol] { get }
    func start()
}

final class AppCoordinator: CoordinatorProtocol{
    private(set) var childCoordinators: [CoordinatorProtocol] = []

    private let window: UIWindow
    private let webService = NewsWebService()

    init(window: UIWindow) {
        self.window = window
    }

    func start(){
        let navigationController = UINavigationController()
        let newsCoordinator = SourcesCoordinator(navigationController: navigationController)
        newsCoordinator.webService = webService
        childCoordinators.append(newsCoordinator)
        newsCoordinator.start()
    
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
