//
//  StoryboardManager.swift
//  Ilke News
//
//  Created by ilke yucel on 7.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import Foundation

import UIKit

struct Storyboards {
    public static let launchScreen = "LaunchScreen"
    public static let main = "Main"
}

extension String {

    var storyboard: UIStoryboard {
        return UIStoryboard(name: self, bundle: nil)
    }

    var initialViewController: UIViewController {
        return storyboard.instantiateInitialViewController()!
    }

    func viewController<T: UIViewController>(identifier: String = T.identifier) -> T {
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }

}

extension UIStoryboard {

    func viewController(identifier: String) -> UIViewController {
        return instantiateViewController(withIdentifier: identifier)
    }

}

