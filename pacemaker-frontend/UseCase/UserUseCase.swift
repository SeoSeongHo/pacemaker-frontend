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
}

final class DefaultUserUseCase: UserUseCase {
    func signin(email: String, password: String) -> Single<User> {
        .just(User(email: "mockdata@mock.com"))
    }
}
