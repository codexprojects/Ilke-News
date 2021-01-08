//
//  CategoriesCell.swift
//  Ilke News
//
//  Created by ilke yucel on 8.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import UIKit

class CategoriesCell: UICollectionViewCell {
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var selectedIcon: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    var selectedCellState = false

}
