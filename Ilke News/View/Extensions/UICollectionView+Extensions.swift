//
//  UICollectionView+Extensions.swift
//  Ilke News
//
//  Created by ilke yucel on 8.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import UIKit

extension UICollectionView {

    func registerCellFromNib<Cell: UICollectionViewCell>(_ cellClass: Cell.Type, nibName: String = Cell.defaultReuseIdentifier, identifier: String = Cell.defaultReuseIdentifier) {
        self.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: identifier)
    }
}
