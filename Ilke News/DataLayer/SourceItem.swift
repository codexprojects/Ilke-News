//
//  SourceItem.swift
//  Ilke News
//
//  Created by ilke yucel on 7.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import Foundation

enum Category: String {
    case business
    case entertainment
    case general
    case health
    case science
    case sports
    case technology
}

final class SourceItem: Codable {
    var status: String!
    var totalResults: Int?
    var sources: [SourceDetail]?
    var code: String?
    var message: String?
}

final class SourceDetail: Codable {
    var id: String!
    var name: String!
    var description: String!
    var url: String!
    var category: String!
    var language: String!
    var country: String!
}
