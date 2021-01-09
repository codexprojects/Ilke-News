//
//  UITableView+Extensions.swift
//  Ilke News
//
//  Created by ilke yucel on 8.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import UIKit

extension UITableView {

    func registerCellFromNib<Cell: UITableViewCell>(_ cellClass: Cell.Type, nibName: String = Cell.defaultReuseIdentifier, identifier: String = Cell.defaultReuseIdentifier) {

        guard let _ = Bundle.main.path(forResource: nibName, ofType: "nib") else {
            self.register(cellClass, forCellReuseIdentifier: identifier)
            return
        }
        self.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: identifier)
    }

    func dequeueReusableCell<Cell: UITableViewCell>(identifier: String = Cell.defaultReuseIdentifier, indexPath: IndexPath) -> Cell {
        (self.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Cell)!
    }

}
