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
    case unknownResponse
    case statusError
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func callBoxOffice(term: String) -> Observable<iTunes> {
        let url = "https://itunes.apple.com/search?\(term)"
        
        let result = Observable<iTunes>.create { observer in
            guard let url = URL(string: url) else {
                observer.onError(APIError.invalidURL)
                return Disposables.create()
            }
            URLSession.shared.dataTask(with: url) {
            
        }
    }
}
