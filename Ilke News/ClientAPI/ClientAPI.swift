//
//  ClientAPI.swift
//  Ilke News
//
//  Created by ilke yucel on 7.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import Foundation

struct APIHost{
    static let `extension` = "https"
    static let host = "newsapi.org"
    static let headlinesUrl = "/v2/top-headlines"
    static let sourcesUrl = "/v2/sources"
    static let apiKey = "d3fbf7edd7184132a29d30d3cf244b4e" //Generated from newsapi.org
}

typealias HeadlineResponseObject = (HeadlineItem?, HTTPError?) -> ()
typealias SourceResponseObject = (SourceItem?, HTTPError?) -> ()

protocol NewsServiceProtocol: class {
    func getHeadlinesList(source: String, completion: @escaping HeadlineResponseObject)
    func getSourcesList(completion: @escaping SourceResponseObject)
}

final class NewsWebService: NewsServiceProtocol {
    var dataService: ServiceProtocol!

    init(dataService: ServiceProtocol = Service()) {
        self.dataService = dataService
    }

    private var urlBuilder: URLComponents = {
        var urlBuilder = URLComponents()
        urlBuilder.scheme = APIHost.extension
        urlBuilder.host = APIHost.host
        return urlBuilder
    }()

    func getHeadlinesList(source:String, completion: @escaping HeadlineResponseObject){
        urlBuilder.path = APIHost.headlinesUrl
        urlBuilder.queryItems = [
            URLQueryItem(name: "sources", value: source),
            URLQueryItem(name: "apiKey", value: APIHost.apiKey)
        ]

        guard let url = urlBuilder.url else { return }
        getNewsHeadlines(for: url, completion: completion)
    }

    func getSourcesList(completion: @escaping SourceResponseObject){
        urlBuilder.path = APIHost.sourcesUrl
        urlBuilder.queryItems = [
            URLQueryItem(name: "lang", value: "en"),
            URLQueryItem(name: "apiKey", value: APIHost.apiKey)
        ]

        guard let url = urlBuilder.url else { return }
        getNewsSources(for: url, completion: completion)
    }

    private func getNewsHeadlines(for url: URL, completion: @escaping HeadlineResponseObject){
        dataService.fetchData(for: url) { (data, err) in

            guard err == nil else{
                completion(nil, err)
                return
            }

            guard let data = data else {return}

            do {
                let decoder = JSONDecoder()
                let object: HeadlineItem = try decoder.decode(HeadlineItem.self, from: data)
                completion(object, nil)
            } catch {
                debugPrint("Unable to decode data: \(error.localizedDescription)")
                completion(nil, .invalidData)
            }
        }
    }

    private func getNewsSources(for url: URL, completion: @escaping SourceResponseObject){
        dataService.fetchData(for: url) { (data, err) in

            guard err == nil else{
                completion(nil, err)
                return
            }

            guard let data = data else {return}

            do {
                let decoder = JSONDecoder()
                let object: SourceItem = try decoder.decode(SourceItem.self, from: data)
                completion(object, nil)
            } catch {
                debugPrint("Unable to decode data: \(error.localizedDescription)")
                completion(nil, .invalidData)
            }
        }
    }
}
