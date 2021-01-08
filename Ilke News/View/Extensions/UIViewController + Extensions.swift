//
//  UIViewController + Extensions.swift
//  Ilke News
//
//  Created by ilke yucel on 7.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import UIKit

extension UIViewController{
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


extension UIViewController {

    static func createWithNib(nibName: String? = nil) -> Self {
        func createWithNib<T: UIViewController>(nibName: String?) -> T {
            let nibName = nibName ?? T.identifier
            return T.init(nibName: nibName, bundle: Bundle(for: T.self))
        }

        return createWithNib(nibName: nibName)
    }

    static var identifier: String {
        String(String(describing: self).split(separator: "<").first!)
    }
}
