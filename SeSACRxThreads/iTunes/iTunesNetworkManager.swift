//
//  iTunesNetworkManager.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/10/24.
//

import Foundation
import RxSwift
import Alamofire

enum iTunesAPIError: Error {
    case invalidURL
    case unknwonResponse
    case statusError
}
class iTunesNetworkManager {
    static let shared = iTunesNetworkManager()
    private init() {}
    
    func fetchITunes(term: String) -> Observable<iTunes> {
        let iTunesURL = "http://itunes.apple.com/search?term=\(term)&media=software"
        return Observable.create { observer -> Disposable in
            AF.request(iTunesURL)
                .validate(statusCode: 200...299)
                .responseDecodable(of: iTunes.self) { response in
                    switch response.result {
                    case .success(let success):
                        observer.onNext(success)
                        observer.onCompleted()//구독 중첩 해결
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create()
        }.debug("iTunes API 통신")
    }
    func fetchITunesSingle(term: String) -> Single<iTunes> {
        let iTunesURL = "http://itunes.apple.com/search?term=\(term)&media=software"
        return Single.create { observer in
            AF.request(iTunesURL)
                .validate(statusCode: 200...299)
                .responseDecodable(of: iTunes.self) { response in
                    switch response.result {
                    case .success(let success):
                        observer(.success(success))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }.debug("iTunes API 통신")
    }
    func calliTunes(term: String) -> Observable<iTunes> {
        let url = "http://itunes.apple.com/search?term=\(term)&media=software"
        
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
