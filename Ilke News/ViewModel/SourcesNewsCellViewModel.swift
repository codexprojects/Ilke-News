//
//  SourcesNewsCellViewModel.swift
//  Ilke News
//
//  Created by ilke yucel on 8.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import Foundation

final class SourcesNewsCellViewModel {
    var sourceDetail: SourceDetail

    var id: String{
        return sourceDetail.id
    }

    var name: String{
        return sourceDetail.name
    }

    var description: String?{
        return sourceDetail.description
    }

    var category: String{
        return sourceDetail.category
    }

    init(sourceDetail: SourceDetail) {
        self.sourceDetail = sourceDetail
    }
}
