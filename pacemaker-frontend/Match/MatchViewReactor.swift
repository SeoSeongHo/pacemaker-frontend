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
        var distance: Distance
        var runner: Runner
    }

    enum Action {
        case setDistance(Distance)
        case setRunner(Runner)
    }

    enum Mutation {
        case setDistance(Distance)
        case setRunner(Runner)
    }

    let initialState: State
    private let matchUseCase: MatchUseCase

    init(matchUseCase: MatchUseCase = DefaultMatchUseCase()) {
        self.initialState = State(distance: Distance.short, runner: Runner.two)
        
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
