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

    //SliderCollecitonView
    @IBOutlet weak var sliderCollectionView: UICollectionView!
    @IBOutlet weak var sliderPageView: UIPageControl!
    var timer = Timer()
    var counter = 0

    //Fetch data every 2 min.
    var fetchDataTimer = Timer()

    //TODO: Read list dummy local array.
    var readList : [HeadlinesNewsCellViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        fetchHeadlineNews()
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
        print("Headlines news id: \(viewModel.source.id ?? "-")")
        print("Headlines news id: \(viewModel.source.name ?? "-")")

        //Notifications from View Model
        viewModel.onUpdateNews = { [weak self] in
            print("Finished to load datas: \(self?.viewModel.newsCells.count ?? 0)")
            self?.sliderPageView.numberOfPages = self?.viewModel.newsCells.prefix(3).count ?? 0
            self?.sliderPageView.currentPage = 0
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

        //TODO: Optional read list logic could be updated.
        print("save to user defaults : \(sender.tag)")

        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = headlinesTableView.cellForRow(at: indexPath) as? HeadlinesCell

        let item = viewModel.newsCells[sender.tag]
        if readList.contains(where: { $0.title == item.title }) {
            guard let deselectIndex = readList.firstIndex(where: {$0.title == item.title}) else { return }
            readList.remove(at: deselectIndex)
            cell?.readListActionButton.setTitle("Okuma Listesine Ekle", for: .normal)
        } else {
            readList.append(item)
            cell?.readListActionButton.setTitle("Okuma Listesinden Çıkar", for: .normal)
        }

    }

}

//MARK: - TABLE VIEW METHODS
extension HeadlinesViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.newsCells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: HeadlinesCell = headlinesTableView.dequeueReusableCell(indexPath: indexPath)
        cell.selectionStyle = .none
        let item = viewModel.newsCells[indexPath.row]

        let placeholder = UIImage(named: "placeholder")

        if let urlStr = item.urlToImage, let url = URL(string: urlStr) {
            let resource = ImageResource(downloadURL: url, cacheKey: item.urlToImage)
            cell.urlToImage.kf.setImage(with: resource, placeholder: placeholder, options: [.transition(.fade(0.2))], progressBlock: nil) { _,_,_,_  in }
        }

        cell.titleLabel.text = item.title
        cell.publishedAtLabel.text = item.publishedAt
        cell.readListActionButton.tag = indexPath.row
        cell.readListActionButton.addTarget(self, action: #selector(readListAction), for: .touchUpInside)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
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

        let item = viewModel.newsCells.prefix(3)[indexPath.row]

        let placeholder = UIImage(named: "placeholder")

        if let urlStr = item.urlToImage, let url = URL(string: urlStr) {
            let resource = ImageResource(downloadURL: url, cacheKey: item.urlToImage)
            cell.imageUrl.kf.setImage(with: resource, placeholder: placeholder, options: [.transition(.fade(0.2))], progressBlock: nil) { _,_,_,_  in }
        }

        cell.titleLabel.text = item.title
        cell.publishedAt.text = item.publishedAt

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

