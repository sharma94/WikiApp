//
//  WikipediaNetworking.swift
//  WikiApp
//
//  Created by R M Sharma on 01/06/21.
//

import Foundation

class WikipediaNetworking {
    
    static var appAuthorEmailForAPI = ""
    
    static let shared: WikipediaNetworking = {
        return WikipediaNetworking()
    }()

    static var debugPerformance = false

    private func logMessage(_ message: String) {
        #if DEBUG
        if WikipediaNetworking.debugPerformance {
            print("WikiApp: \(message)")
        }
        #endif
    }

    static weak var sharedActivityIndicatorDelegate: WikipediaNetworkingActivityDelegate?
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    func loadJSON(urlRequest: URLRequest,
                  completion: @escaping (JSONDictionary?, WikipediaError?) -> ())
        -> URLSessionDataTask {

        let startTime: Date
        #if DEBUG
            startTime = Date()
            self.logMessage("Fetching \(urlRequest.url!.absoluteString)")
        #endif
        
        let urlRequest = urlRequest
            
        WikipediaNetworking.sharedActivityIndicatorDelegate?.start()
        let task = session.dataTask(with: urlRequest) { data, response, error in
            WikipediaNetworking.sharedActivityIndicatorDelegate?.stop()

            #if DEBUG
                let endNetworkingTime = Date()
                let totalNetworkingTime: Double = endNetworkingTime.timeIntervalSince(startTime)
                self.logMessage("\(totalNetworkingTime) seconds for network retrieval")
            #endif

            if let error = error {
                var wikipediaError: WikipediaError
                if (error as NSError).code == NSURLErrorCancelled {
                    wikipediaError = .cancelled
                } else {
                    // Fallback description from NSError; tends do be rather user-unfriendly
                    wikipediaError = .other(error.localizedDescription)
                    // See http://nshipster.com/nserror/
                    if (error as NSError).domain == NSURLErrorDomain {
                        switch (error as NSError).code {
                        case NSURLErrorNotConnectedToInternet:
                            fallthrough
                        case NSURLErrorNetworkConnectionLost:
                            fallthrough
                        case NSURLErrorResourceUnavailable:
                            wikipediaError = .noInternetConnection
                        case NSURLErrorBadServerResponse:
                            wikipediaError = .badResponse
                        default: ()
                        }
                    }
                }
                completion(nil, wikipediaError)
                return
            }

            guard let data = data,
                let response = response as? HTTPURLResponse,
                200...299 ~= response.statusCode
                else {
                    completion(nil, .badResponse)
                    return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let jsonDictionary = json as? JSONDictionary
                else {
                    completion(nil, .decodingError)
                    return
            }

            #if DEBUG
                let endTime = NSDate()
                let totalTime = endTime.timeIntervalSince(startTime as Date)
                self.logMessage("\(totalTime) seconds for network retrieval & JSON decoding")
            #endif
            
            completion(jsonDictionary, nil)
        }
        task.resume()
        return task
    }

}
