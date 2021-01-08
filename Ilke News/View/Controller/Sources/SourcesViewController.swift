//
//  SourcesViewController.swift
//  Ilke News
//
//  Created by ilke yucel on 8.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import UIKit

class SourcesViewController: UIViewController {

    var viewModel: NewsSourcesListViewModel!
    var category: Category?

    @IBOutlet weak var sourcesTableView: UITableView!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!

    var categories:[Category] = [.general,
                                 .business,
                                 .entertainment,
                                 .health,
                                 .science,
                                 .sports,
                                 .technology]
    var selectedCategories:[Category] = []
    var filteredArray : [SourcesNewsCellViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        fetchSourcesData()
    }

    func setupView() {
        sourcesTableView.delegate = self
        sourcesTableView.dataSource = self
        sourcesTableView.registerCellFromNib(SourcesCell.self)

        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
        categoriesCollectionView.registerCellFromNib(CategoriesCell.self)
    }

    func fetchSourcesData() {
        viewModel.viewDidLoad()
        //Notifications from View Model
        viewModel.onUpdateNews = { [weak self] in
            print("Finished to load datas: \(self?.viewModel.newsCells.count ?? 0)")
            self?.filteredArray.removeAll()
            self?.filteredArray = self?.viewModel.newsCells ?? []
            self?.sourcesTableView.reloadData()
        }
    }

    func setCategory() {

        //If selected categories is empty fetch sources data again, else filter from local array.
        switch selectedCategories.isEmpty {
        case true:
            fetchSourcesData()
        case false:
            filteredArray.removeAll()
            for i in selectedCategories {
              filteredArray += viewModel.newsCells.filter { i.rawValue.contains($0.category) }
            }
            sourcesTableView.reloadData()
        }

    }

}

//MARK: - TABLE VIEW METHODS
extension SourcesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return filteredArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: SourcesCell = sourcesTableView.dequeueReusableCell(indexPath: indexPath)
        let item = filteredArray[indexPath.row]

        cell.nameHeaderTitleLabel.text = item.name + " - " + item.category
        cell.descriptionLabel.text = item.description

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sourceItem = Source()
        sourceItem.name = filteredArray[indexPath.row].name
        sourceItem.id = filteredArray[indexPath.row].id
        viewModel.newsDidSelect(at: indexPath.row, sourceItem: sourceItem)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}



// MARK: - UICollectionView DataSource
extension SourcesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: CategoriesCell.defaultReuseIdentifier, for: indexPath) as? CategoriesCell else {
            return UICollectionViewCell()
        }
        let item = categories[indexPath.row]
        cell.categoryNameLabel.text = item.rawValue
        cell.stackView.layer.borderWidth = 0.2

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath) as? CategoriesCell
        let selectedCategory = categories[indexPath.row]

        if !selectedCategories.contains(selectedCategory) {
            selectedCategories.append(selectedCategory)
            cell?.selectedIcon.image = UIImage(named: "check")
            cell?.stackView.backgroundColor = .lightGray
        } else {
            guard let deselectIndex = selectedCategories.firstIndex(where: {$0 == selectedCategory}) else { return }
            selectedCategories.remove(at: deselectIndex)
            cell?.selectedIcon.image = UIImage(named: "plus")
            cell?.stackView.backgroundColor = .white
        }

        setCategory()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

    }
}

extension SourcesViewController: UICollectionViewDelegateFlowLayout { }
