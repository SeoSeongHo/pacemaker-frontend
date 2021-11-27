//
//  LoginViewReactor.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/10/17.
//

import ReactorKit
import RxSwift

final class LoginViewReactor: Reactor {
    struct State {
        var email: String?
        var password: String?
        var user: User?
    }

    enum Action {
        case setEmail(String?)
        case setPassword(String?)
        case signin
    }

    enum Mutation {
        case setEmail(String?)
        case setPassword(String?)
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
        case .signin:
            guard let email = currentState.email,
                  !email.isEmpty,
                  let password = currentState.password,
                  !password.isEmpty else {
                // TODO: show error toast
                return .empty()
            }
            Toaster.shared.setLoading(true)
            return userUseCase.signin(email: email, password: password)
                .asObservable()
                .do(onNext: { _ in
                    Toaster.shared.setLoading(false)
                }, onError: { error in
                    Toaster.shared.setLoading(false)
                    Toaster.shared.showToast(.error(error.localizedDescription))
                })
                .map { .setUser($0) }
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
        }
        return newState
    }
}
