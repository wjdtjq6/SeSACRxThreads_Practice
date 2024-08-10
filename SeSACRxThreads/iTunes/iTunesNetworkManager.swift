//
//  iTunesNetworkManager.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/10/24.
//

import Foundation
import RxSwift
enum iTunesAPIError: Error {
    case invalidURL
    case unknwonResponse
    case statusError
}
class iTunesNetworkManager {
    static let shared = iTunesNetworkManager()
    private init() {}
    
    func calliTunes(term: String) -> Observable<iTunes> {
        let url = "http://itunes.apple.com/search?term=\(term)"
        
        let result = Observable<iTunes>.create { observer in
            guard let url = URL(string: url) else {
                observer.onError(APIError.invalidURL)
                return Disposables.create()
            }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    observer.onError(iTunesAPIError.unknwonResponse)
                    return
                }
                guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    observer.onError(iTunesAPIError.statusError)
                    return
                }
                
                if let data = data, let appData = try? JSONDecoder().decode(iTunes.self, from: data) {
                    observer.onNext(appData)
                    observer.onCompleted()//Observable lifeCycle에 의해 알아서 dispose되도록 만들 수 있음
                } else {
                    print("응답은 왔으나 디코딩 실패")
                    observer.onError(APIError.unknwonResponse)
                }
            }.resume()
            return Disposables.create()
        }
            .debug()
        return result
    }
}
