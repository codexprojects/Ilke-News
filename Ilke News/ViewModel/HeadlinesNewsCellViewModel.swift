//
//  NewsCellViewModel.swift
//  Ilke News
//
//  Created by ilke yucel on 7.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import Foundation

final class HeadlinesNewsCellViewModel {
    var article: Article

    var title: String {
        return article.title
    }

    var url: String {
        return article.url
    }

    var urlToImage: String? {
        return article.urlToImage
    }

    var sourceName: String {
        return article.source.name
    }

    var publishedAt: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: article.publishedAt) else { return "-" }
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .none
        return dateFormatter.string(from: date)
    }

    init(article: Article) {
        self.article = article
    }
}
