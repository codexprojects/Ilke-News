//
//  SourceItem.swift
//  Ilke News
//
//  Created by ilke yucel on 7.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import Foundation

enum CellType: String {
    case news
    case slider
}

final class HeadlineItem: Codable {
    var status: String!
    var totalResults: Int?
    var articles: [Article]?
    var code: String?
    var message: String?
}

final class Article: Codable {
    var source: Source!
    var title: String!
    var url: String!
    var urlToImage: String!
    var publishedAt: String!
}

final class Source: Codable {
    var id: String!
    var name: String!
}
