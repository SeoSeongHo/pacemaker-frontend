//
//  RequestManager.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/11/27.
//

import RxSwift
import RxCocoa
import Alamofire
import AlamofireNetworkActivityLogger

enum RequestError: Error, LocalizedError {
    case invalidPath
    case networkError
    case typeError
    case invalidParameters
    case tokenExpired
}

enum CommonError: Error, LocalizedError {
    case nilSelf
}

protocol RequestManager {
    var baseURL: String { get }
    func get<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T>
    func post<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T>
    func post(_ path: String, parameters: [String: Any]?) -> Completable
}

extension RequestManager { // implement func with default value
    func get<T: Codable>(_ path: String, responseType: T.Type) -> Single<T> {
        return get(path, parameters: nil, responseType: T.self)
    }
    func post<T: Codable>(_ path: String, responseType: T.Type) -> Single<T> {
        return post(path, parameters: nil, responseType: T.self)
    }

    func post(_ path: String) -> Completable {
        return post(path, parameters: nil)
    }
}

final class DefaultRequestManager: RequestManager {
    static let shared = DefaultRequestManager()
    var baseURL = "http://3.38.94.54"
    private let sessionManager: SessionManager

    init(sessionManager: SessionManager = DefaultSessionManager.shared) {
        self.sessionManager = sessionManager
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
    }

    private var headers: HTTPHeaders {
        var header: HTTPHeaders = ["Content-Type": "application/json"]
        if let token = sessionManager.token {
            header["Authorization"] = "Bearer \(token)"
        }
        return header
    }

    private func request<T: Codable>(_ path: String, method: HTTPMethod, parameters: Parameters?, responseType: T.Type) -> Single<T> {
        return Single.create { [unowned self] single in
            guard let url = URL(string: self.baseURL + path) else {
                single(.failure(RequestError.invalidPath))
                return Disposables.create()
            }
            let encoding: ParameterEncoding = {
                switch method {
                case .post:
                    return JSONEncoding.default
                default:
                    return URLEncoding.default
                }
            }()
            let request = AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
                .responseJSON { response in
                    let decoder = JSONDecoder()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    decoder.dateDecodingStrategy = .formatted(dateFormatter)

                    guard let _ = response.value, let data = response.data else {
                        single(.failure(RequestError.networkError))
                        return
                    }
                    guard response.error == nil else {
                        single(.failure(RequestError.networkError))
                        return
                    }

                    do {
                        let value = try decoder.decode(T.self, from: data)
                        single(.success(value))
                    } catch {
                        single(.failure(RequestError.typeError))
                    }
                }
            return Disposables.create {
                request.cancel()
            }
        }
    }

    func get<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T> {
        return request(path, method: .get, parameters: parameters, responseType: T.self)
    }

    func post<T: Codable>(_ path: String, parameters: [String: Any]?, responseType: T.Type) -> Single<T> {
        return request(path, method: .post, parameters: parameters, responseType: T.self)
    }

    func post(_ path: String, parameters: [String: Any]?) -> Completable {
        return Completable.create { [unowned self] single in
            guard let url = URL(string: self.baseURL + path) else {
                single(.error(RequestError.invalidPath))
                return Disposables.create()
            }
            let request = AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseJSON { response in
                    guard let _ = response.value, let _ = response.data else {
                        single(.error(RequestError.networkError))
                        return
                    }
                    single(.completed)
                }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

