//
//  SignupViewReactor.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/10/17.
//

import ReactorKit
import RxSwift

final class SignupViewReactor: Reactor {
    struct State {
        var email: String?
        var password: String?
        var nickname: String?
        var user : User?
    }

    enum Action {
        case setEmail(String?)
        case setPassword(String?)
        case setNickname(String?)
        case signup
    }

    enum Mutation {
        case setEmail(String?)
        case setPassword(String?)
        case setNickname(String?)
        case setUser(User)
    }

    let initialState: State
    private let userUseCase: UserUseCase

    init(userUseCase: UserUseCase = DefaultUserUseCase.shared) {
        self.initialState = State()
        self.userUseCase = userUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setEmail(let email):
            return .just(.setEmail(email))
        case .setPassword(let password):
            return .just(.setPassword(password))
        case .signup:
            guard let email = currentState.email,
                  let password = currentState.password,
                  let nickname = currentState.nickname,
                  !email.isEmpty,
                  !password.isEmpty,
                  !nickname.isEmpty else {
                Toaster.shared.showToast(.error("There is unentered field"))
                return .empty()
            }
            Toaster.shared.setLoading(true)
            return userUseCase.signup(email: email, password: password, nickname: nickname)
                .asObservable()
                .map { .setUser($0.user) }
                .do(onNext: { _ in
                    Toaster.shared.setLoading(false)
                    Toaster.shared.showToast(.success("Signup completed"))
                }, onError: { error in
                    Toaster.shared.setLoading(false)
                    Toaster.shared.showToast(.error(error.localizedDescription))
                })
        case .setNickname(let nickname):
            return .just(.setNickname(nickname))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setEmail(let email):
            newState.email = email
        case .setPassword(let password):
            newState.password = password
        case .setUser(let user):
            newState.user = user
        case .setNickname(let nickname):
            newState.nickname = nickname
        }
        return newState
    }
}
