//
//  Service.swift
//  Ilke News
//
//  Created by ilke yucel on 7.01.2021.
//  Copyright © 2021 Ilke Yucel. All rights reserved.
//

import Foundation

enum HTTPError: Error {
    case invalidResponse, noData, failedRequest, invalidData
}

typealias FetchDataCompletion = (Data?, HTTPError?) -> Void
typealias CancelCompletion = () -> Void

protocol ServiceProtocol {
    func fetchData(for url: URL, completion: @escaping (Data?, HTTPError?) -> Void)
    func cancel()
}

final class Service: ServiceProtocol {
    private var task: URLSessionDataTask!

    func fetchData(for url: URL, completion: @escaping (Data?, HTTPError?) -> Void) {
        let session: URLSession = .shared
        task = session.dataTask(with: url) { (data, response, error) in

            DispatchQueue.main.async {

                guard error == nil else {
                    debugPrint("The request is failed: \(error!.localizedDescription)")
                    completion(nil, .failedRequest)
                    return
                }

                guard let response = response as? HTTPURLResponse else {
                    debugPrint("Unable to process response")
                    completion(nil, .invalidResponse)
                    return
                }

                guard response.statusCode == 200 else {
                    debugPrint("Failure response: \(response.statusCode)")
                    completion(nil, .failedRequest)
                    return
                }

                guard let data = data else {
                    debugPrint("No data returned")
                    completion(nil, .noData)
                    return
                }

                completion(data, nil)

            }

        }

        task.resume()
    }

    func cancel() {
        task?.cancel()
    }

}
