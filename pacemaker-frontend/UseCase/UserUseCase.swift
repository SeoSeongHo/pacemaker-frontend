//
//  UserUseCase.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/10/22.
//

import Foundation
import RxSwift

protocol UserUseCase {
    func signin(email: String, password: String) -> Single<User>
    func signup(email: String, password: String, nickname: String) -> Single<SignupResponse>
}

final class DefaultUserUseCase: UserUseCase {
    static let shared = DefaultUserUseCase()
    private let sessionManager: SessionManager = DefaultSessionManager.shared
    private let requestManager: RequestManager = DefaultRequestManager.shared

    func signin(email: String, password: String) -> Single<User> {
//        return .just(User(id: 1, email: "", nickname: ""))

        return requestManager.post(
            "/api/v1/users/signin",
            parameters: [
                "email": email,
                "password": password
            ],
            responseType: SignupResponse.self
        ).map { [sessionManager] response in
            sessionManager.user = response.user
            sessionManager.token = response.token
            return response.user
        }
    }
    
    func signup(email: String, password: String, nickname: String) -> Single<SignupResponse> {
        return requestManager.post(
            "/api/v1/users/signup",
            parameters: [
                "email": email,
                "password": password,
                "nickname": nickname
            ],
            responseType: SignupResponse.self
        )
    }
}
