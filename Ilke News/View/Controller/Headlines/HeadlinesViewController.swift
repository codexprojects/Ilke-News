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
    @IBOutlet weak var headlinesCollectionView: UICollectionView!

    // SliderCollecitonView
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var sliderPageView: UIPageControl!
    var timer: Timer!
    var counter = 0

    // Fetch data every 2 min.
    var fetchDataTimer: Timer!
    let userDefaults = UserDefaults.standard

    // Main and slider datas
    var mainDataArray: [HeadlinesNewsCellViewModel]?
    var sliderDataArray: [HeadlinesNewsCellViewModel]?

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
        sliderCollectionView.delegate = self
        sliderCollectionView.dataSource = self
        sliderCollectionView.registerCellFromNib(SliderCell.self)
        sliderCollectionView.tag = 100

        headlinesCollectionView.delegate = self
        headlinesCollectionView.dataSource = self
        headlinesCollectionView.registerCellFromNib(SliderCell.self)
        headlinesCollectionView.tag = 200

        DispatchQueue.main.async {
            self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.changeImage), userInfo: nil, repeats: true)
            self.fetchDataTimer =  Timer.scheduledTimer(timeInterval: 120.0, target: self, selector: #selector(self.fetchHeadlineNews), userInfo: nil, repeats: true)
        }
        
    }

    @objc func fetchHeadlineNews() {
        viewModel.viewDidLoad()
        // Notifications from View Model
        viewModel.onUpdateNews = { [weak self] in
            self?.mainDataArray?.removeAll()
            self?.sliderDataArray?.removeAll()

            func processResponseData(responseData: [HeadlinesNewsCellViewModel], type: CellType) -> [HeadlinesNewsCellViewModel] {

                var processedDataArray: [HeadlinesNewsCellViewModel] = []

                switch type {
                case .news:
                    let deletedIndexes = [0, 1, 2]
                    processedDataArray = responseData
                        .enumerated()
                        .filter { !deletedIndexes.contains($0.offset) }
                        .map { $0.element }
                    return processedDataArray
                case .slider:
                    processedDataArray = responseData.enumerated().compactMap { $0.offset < 3 ? $0.element : nil }
                    return processedDataArray
                }
            }

            self?.mainDataArray = processResponseData(responseData: self?.viewModel.newsCells ?? [], type: .news)
            self?.sliderDataArray = processResponseData(responseData: self?.viewModel.newsCells ?? [], type: .slider
            )

            self?.sliderPageView.numberOfPages = self?.sliderDataArray?.count ?? 0
            self?.sliderPageView.currentPage = 0

            guard let readList = self?.userDefaults.object(forKey: ReadList.ReadListKey.readList) as? [String: String] else {
                self?.sliderCollectionView.reloadData()
                self?.headlinesCollectionView.reloadData()
                return }

            for (index, element) in readList.enumerated() {
                for item in (self?.mainDataArray)! {
                    if element.value == item.title {
                        guard let itemIndex = self?.mainDataArray?.firstIndex(where: {$0.title == element.value}) else { return }
                        self?.mainDataArray?[itemIndex].isReadList = true
                    }
                }

                for item in (self?.sliderDataArray)! {
                    if element.value == item.title {
                        guard let itemIndex = self?.sliderDataArray?.firstIndex(where: {$0.title == element.value}) else { return }
                        self?.sliderDataArray?[itemIndex].isReadList = true
                    }
                }
            }
            self?.sliderCollectionView.reloadData()
            self?.headlinesCollectionView.reloadData()
        }
    }

    @objc func changeImage() {

        if counter < sliderDataArray!.count {
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

    func readListAction(_ cellType: CellType, indexPath: IndexPath) {
        var cell = SliderCell()
        var item: HeadlinesNewsCellViewModel?

        switch cellType {
        case .news:
            item = mainDataArray?[indexPath.row]
            cell = (headlinesCollectionView.cellForItem(at: indexPath) as? SliderCell)!
        case .slider:
            item = sliderDataArray?[indexPath.row]
            cell = (sliderCollectionView.cellForItem(at: indexPath) as? SliderCell)!
        }

        guard let readList = userDefaults.object(forKey: ReadList.ReadListKey.readList) as? [String: String] else {
            let dictionary = [item?.title: item?.title]
            userDefaults.set(dictionary, forKey: ReadList.ReadListKey.readList)
            userDefaults.synchronize()
            item?.isReadList = true
            cell.readListActionButton.setTitle("Okuma Listesinden Çıkar", for: .normal)
            return
        }

        if readList.contains(where: { $0.value == item!.title }) {
            guard let deselectIndex = readList.firstIndex(where: {$0.value == item!.title}) else { return }
            var updatedList = readList
            updatedList.remove(at: deselectIndex)
            userDefaults.set(updatedList, forKey: ReadList.ReadListKey.readList)
            userDefaults.synchronize()
            item?.isReadList = false
            cell.readListActionButton.setTitle("Okuma Listesine Ekle", for: .normal)
        } else {
            var updatedList = userDefaults.object(forKey: ReadList.ReadListKey.readList) as? [String: String]
            updatedList?.updateValue(item!.title, forKey: item!.title)

            userDefaults.set(updatedList, forKey: ReadList.ReadListKey.readList)
            userDefaults.synchronize()
            item?.isReadList = true
            cell.readListActionButton.setTitle("Okuma Listesinden Çıkar", for: .normal)
        }
    }
}

// MARK: - UICollectionView DataSource
extension HeadlinesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 100:
            return sliderDataArray?.count ?? 0
        case 200:
            return mainDataArray?.count ?? 0
        default:
            return 0
        }

    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = sliderCollectionView.dequeueReusableCell(withReuseIdentifier: SliderCell.defaultReuseIdentifier, for: indexPath) as? SliderCell else {
            return UICollectionViewCell()
        }
        var item: HeadlinesNewsCellViewModel?

        switch collectionView.tag {
        case 100:
            item = sliderDataArray?[indexPath.row]
        default:
            item = mainDataArray?[indexPath.row]
        }

        guard let cellItem = item else { return cell }
        let placeholder = UIImage(named: "placeholder")

        if let urlStr = cellItem.urlToImage, let url = URL(string: urlStr) {
            let resource = ImageResource(downloadURL: url, cacheKey: cellItem.urlToImage)
            cell.imageUrl.kf.setImage(with: resource, placeholder: placeholder, options: [.transition(.fade(0.2))], progressBlock: nil) { _, _, _, _  in }
        }

        cell.titleLabel.text = cellItem.title
        cell.publishedAt.text = cellItem.publishedAt
        if cellItem.isReadList {
            cell.readListActionButton.setTitle("Okuma Listesinden Çıkar", for: .normal)
        } else {
            cell.readListActionButton.setTitle("Okuma Listesine Ekle", for: .normal)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag {
        case 100:
            readListAction(.slider, indexPath: indexPath)
        case 200:
            readListAction(.news, indexPath: indexPath)
        default:
            return
        }

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
