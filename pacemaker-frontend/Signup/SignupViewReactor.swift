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

    }

    enum Action {

    }

    enum Mutation {

    }

    let initialState: State

    init() {
        self.initialState = State()
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {

        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {

        }
        return newState
    }
}
