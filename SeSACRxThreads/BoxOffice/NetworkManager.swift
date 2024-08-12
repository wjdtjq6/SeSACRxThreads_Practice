//
//  NetworkManager.swift
//  SeSACRxThreads
//
//  Created by 소정섭 on 8/9/24.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

enum APIError: Error {
    case invalidURL
    case unknwonResponse
    case statusError
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    static let jokeURL = "https://v2.jokeapi.dev/joke/Programmin?type=single"
    //Observeablerorcpfh Alamofire 통신[오류 시 멈춤]
    func fetchJoke() -> Observable<Joke> {
        return Observable.create { observer -> Disposable in
            AF.request(NetworkManager.jokeURL)
                .validate(statusCode: 200...299)
                .responseDecodable(of: Joke.self) { response in
                    switch response.result {
                    case .success(let success):
                        observer.onNext(success)
                        observer.onCompleted()//구독 중첩 해결
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create()
        }.debug("Joke API 통신")
    }
    //Single객체로 Alamofire 통신[오류나도 통신 가능]
    func fetchJokeWithSingle() -> Single<Joke> {
        return Single.create { observer -> Disposable in
            AF.request(NetworkManager.jokeURL)
                .validate(statusCode: 200...299)
                .responseDecodable(of: Joke.self) { response in
                    switch response.result {
                    case .success(let success):
                        observer(.success(success))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }.debug("Joke API 통신")
    }
    //Single객체로 Alamofire 통신 + Resu;t Type 활용
    func fetchJokeWithSingleResultType() {
        
    }
    func callBoxOffice(date: String) -> Observable<Movie> {
        let url = "https://kobis.or.kr/kobisopenapi/webservice/rest/boxoffice/searchDailyBoxOfficeList.json?key=dd105b2a5afdd9b737046ac209a6a4da&targetDt=\(date)"
        
        let result = Observable<Movie>.create { observer in
            guard let url = URL(string: url) else {
                observer.onError(APIError.unknwonResponse)
                return Disposables.create()
            }
            URLSession.shared.dataTask(with: url) { data, reponse, error in
                if let error = error {
                    observer.onError(APIError.unknwonResponse)
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
                    observer.onError(APIError.unknwonResponse)
                }
            }.resume()
            return Disposables.create()
        }
            .debug()
        return result
    }
}
