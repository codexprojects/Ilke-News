//
//  UIView+Extensions.swift
//  Ilke News
//
//  Created by ilke yucel on 8.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import UIKit

extension UIView {

    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return (nib.instantiate(withOwner: self, options: nil).first as? UIView)!
    }

    /// Default identifier to reuse in tableview, collectionview, map annotation etc.
    static var defaultReuseIdentifier: String {
        guard let substring: Substring = String(describing: self).split(separator: "<").first else {
            return String(describing: self)
        }
        return String(substring)
    }

}
