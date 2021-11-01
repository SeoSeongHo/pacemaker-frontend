//
//  MatchViewReactor.swift
//  pacemaker-frontend
//
//  Created by 이지원 on 2021/11/01.
//

import ReactorKit
import RxSwift

final class MatchViewReactor: Reactor {
    struct State {
        var distance: String?
        var runner: String?
        var user: User?
    }

    enum Action {
        case setDistance(String?)
        case setRunner(String?)
    }

    enum Mutation {
        case setDistance(String?)
        case setRunner(String?)
    }

    let initialState: State
    private let matchUseCase: MatchUseCase

    init(matchUseCase: MatchUseCase = DefaultMatchUseCase()) {
        self.initialState = State()
        self.matchUseCase = matchUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setDistance(let distance):
            return .just(.setDistance(distance))
        case .setRunner(let runner):
            return .just(.setRunner(runner))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setDistance(let distance):
            newState.distance = distance
        case .setRunner(let runner):
            newState.runner = runner
        }
        return newState
    }
}
