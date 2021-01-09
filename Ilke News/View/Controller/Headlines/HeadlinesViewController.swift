//
//  HeadlinesViewController.swift
//  Ilke News
//
//  Created by ilke yucel on 7.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import UIKit
import Kingfisher

class HeadlinesViewController: UIViewController {

    var viewModel: NewsListViewModel!

    @IBOutlet weak var headlinesTableView: UITableView!

    // SliderCollecitonView
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var sliderPageView: UIPageControl!
    var timer: Timer!
    var counter = 0
    var filteredArray: [HeadlinesNewsCellViewModel]?

    // Fetch data every 2 min.
    var fetchDataTimer: Timer!

    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        fetchHeadlineNews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        timer.invalidate()
        fetchDataTimer.invalidate()
        timer = nil
        fetchDataTimer = nil
    }

    func setupView() {
        headlinesTableView.delegate = self
        headlinesTableView.dataSource = self
        headlinesTableView.registerCellFromNib(HeadlinesCell.self)

        sliderCollectionView.delegate = self
        sliderCollectionView.dataSource = self
        sliderCollectionView.registerCellFromNib(SliderCell.self)

        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
            self.fetchDataTimer =  Timer.scheduledTimer(timeInterval: 120.0, target: self, selector: #selector(self.fetchHeadlineNews), userInfo: nil, repeats: true)
        }
        
    }

    @objc func fetchHeadlineNews() {
        viewModel.viewDidLoad()
        // Notifications from View Model
        viewModel.onUpdateNews = { [weak self] in
            self?.sliderPageView.numberOfPages = self?.viewModel.newsCells.prefix(3).count ?? 0
            self?.sliderPageView.currentPage = 0

            let deletedIndexes = [0, 1, 2, 3]
            self?.filteredArray = self?.viewModel.newsCells
                .enumerated()
                .filter { !deletedIndexes.contains($0.offset) }
                .map { $0.element } ?? []

            guard let readList = self?.userDefaults.object(forKey: "ReadList") as? [String: String] else {
                self?.headlinesTableView.reloadData()
                self?.sliderCollectionView.reloadData()
                return }

            for (index, element) in readList.enumerated() {
                for item in (self?.filteredArray)! {
                    if element.value == item.title {
                        guard let itemIndex = self?.filteredArray?.firstIndex(where: {$0.title == element.value}) else { return }
                        self?.filteredArray?[itemIndex].isReadList = true
                    }
                }

                for item in (self?.viewModel.newsCells)! {
                    if element.value == item.title {
                        guard let itemIndex = self?.viewModel.newsCells.firstIndex(where: {$0.title == element.value}) else { return }
                        self?.viewModel.newsCells[itemIndex].isReadList = true
                    }
                }
            }

            self?.headlinesTableView.reloadData()
            self?.sliderCollectionView.reloadData()
        }
    }

    @objc func changeImage() {

     if counter < viewModel.newsCells.prefix(3).count {
        let index = IndexPath.init(item: counter, section: 0)
        self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
        sliderPageView.currentPage = counter
         counter += 1
     } else {
         counter = 0
         let index = IndexPath.init(item: counter, section: 0)
         self.sliderCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: false)
         sliderPageView.currentPage = counter
         counter = 1
         }
     }

    @objc func readListAction(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = headlinesTableView.cellForRow(at: indexPath) as? HeadlinesCell
        let sliderCell = sliderCollectionView.cellForItem(at: indexPath) as? SliderCell
        var item: HeadlinesNewsCellViewModel?

        switch sender.superview?.tag {
        case 0:
            item = filteredArray?[sender.tag]
        case 1:
            item = viewModel.newsCells[sender.tag]
        default:
            return
        }

        guard let readList = userDefaults.object(forKey: "ReadList") as? [String: String] else {
            let dictionary = ["title": item!.title]
            userDefaults.set(dictionary, forKey: "ReadList")
            userDefaults.synchronize()
            if sender.superview?.tag == 0 {
                item?.isReadList = true
                cell?.readListActionButton.setTitle("Okuma Listesinden Çıkar", for: .normal)
            } else {
                item?.isReadList = true
                sliderCell?.readListActionButton.setTitle("Okuma Listesinden Çıkar", for: .normal)
            }
            return
        }

        if readList.contains(where: { $0.value == item!.title }) {
            guard let deselectIndex = readList.firstIndex(where: {$0.value == item!.title}) else { return }
            var updatedList = readList
            updatedList.remove(at: deselectIndex)
            userDefaults.set(updatedList, forKey: "ReadList")
            userDefaults.synchronize()
            if sender.superview?.tag == 0 {
                cell?.readListActionButton.setTitle("Okuma Listesine Ekle", for: .normal)
            } else {
                item?.isReadList = false
                sliderCell?.readListActionButton.setTitle("Okuma Listesine Ekle", for: .normal)
            }
        } else {
            var updatedList = userDefaults.object(forKey: "ReadList") as? [String: String]
            updatedList?.updateValue(item!.title, forKey: "title")
            userDefaults.set(updatedList, forKey: "ReadList")
            userDefaults.synchronize()
            if sender.superview?.tag == 0 {
                cell?.readListActionButton.setTitle("Okuma Listesinden Çıkar", for: .normal)
            } else {
                item?.isReadList = true
                sliderCell?.readListActionButton.setTitle("Okuma Listesinden Çıkar", for: .normal)
            }
        }

    }

}

// MARK: - TABLE VIEW METHODS
extension HeadlinesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArray?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: HeadlinesCell = headlinesTableView.dequeueReusableCell(indexPath: indexPath)
        cell.selectionStyle = .none
        guard let item = filteredArray?[indexPath.row] else { return cell }

        let placeholder = UIImage(named: "placeholder")

        if let urlStr = item.urlToImage, let url = URL(string: urlStr) {
            let resource = ImageResource(downloadURL: url, cacheKey: item.urlToImage)
            cell.urlToImage.kf.setImage(with: resource, placeholder: placeholder, options: [.transition(.fade(0.2))], progressBlock: nil) { _, _, _, _  in }
        }

        cell.titleLabel.text = item.title
        cell.publishedAtLabel.text = item.publishedAt
        if item.isReadList {
            cell.readListActionButton.setTitle("Okuma Listesinden Çıkar", for: .normal)
        } else {
            cell.readListActionButton.setTitle("Okuma Listesine Ekle", for: .normal)
        }
        cell.readListActionButton.tag = indexPath.row
        cell.readListActionButton.superview?.tag = 0
        cell.readListActionButton.addTarget(self, action: #selector(readListAction), for: .touchUpInside)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 235
    }
}

// MARK: - UICollectionView DataSource
extension HeadlinesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.newsCells.prefix(3).count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = sliderCollectionView.dequeueReusableCell(withReuseIdentifier: SliderCell.defaultReuseIdentifier, for: indexPath) as? SliderCell else {
            return UICollectionViewCell()
        }

        let item = viewModel.newsCells[indexPath.row]

        let placeholder = UIImage(named: "placeholder")

        if let urlStr = item.urlToImage, let url = URL(string: urlStr) {
            let resource = ImageResource(downloadURL: url, cacheKey: item.urlToImage)
            cell.imageUrl.kf.setImage(with: resource, placeholder: placeholder, options: [.transition(.fade(0.2))], progressBlock: nil) { _, _, _, _  in }
        }

        cell.titleLabel.text = item.title
        cell.publishedAt.text = item.publishedAt
        if item.isReadList {
            cell.readListActionButton.setTitle("Okuma Listesinden Çıkar", for: .normal)
        } else {
            cell.readListActionButton.setTitle("Okuma Listesine Ekle", for: .normal)
        }
        cell.readListActionButton.tag = indexPath.row
        cell.readListActionButton.superview?.tag = 1
        cell.readListActionButton.addTarget(self, action: #selector(readListAction), for: .touchUpInside)

        return cell
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

    }
}

extension HeadlinesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = sliderCollectionView.frame.size
        return CGSize(width: size.width, height: size.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
