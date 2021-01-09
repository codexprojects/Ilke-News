//
//  AppDelegate.swift
//  Ilke News
//
//  Created by ilke yucel on 7.01.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        appCoordinator = AppCoordinator(window: window!)
        appCoordinator?.start()
        return true
    }

}
