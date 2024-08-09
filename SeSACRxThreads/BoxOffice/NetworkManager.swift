//
//  NetworkManager.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/9/24.
//

import Foundation
import RxSwift

enum APIError: Error {
    case invalidURL
    case unkwnonResponse
    case statusError
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func callBoxOffice(date: String) -> Observable<Movie> {
        let url = "https://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=dd105b2a5afdd9b737046ac209a6a4da&targetDt=\(date)"
        
        let result = Observable<Movie>.create { observer in
            guard let url = URL(string: url) else {
                observer.onError(APIError.unkwnonResponse)
                return Disposables.create()
            }
            URLSession.shared.dataTask(with: url) { data, reponse, error in
                if let error = error {
                    observer.onError(APIError.unkwnonResponse)
                    return
                }
                guard let response = reponse as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    observer.onError(APIError.statusError)
                    return
                }
                
                if let data = data, let appData = try? JSONDecoder().decode(Movie.self, from: data) {
                    observer.onNext(appData)
                    observer.onCompleted()//Observable lifeCycle에 의해 알아서 dispose되도록 만들 수 있음
                } else {
                    print("응답은 왔으나 디코딩 실패")
                    observer.onError(APIError.unkwnonResponse)
                }
            }.resume()
            return Disposables.create()
        }
            .debug()
        return result
    }
}
