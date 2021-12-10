//
//  HistoryViewReactor.swift
//  pacemaker-frontend
//
//  Created by 이지원 on 2021/11/01.
//

import ReactorKit
import RxSwift

final class HistoryViewReactor: Reactor {
    struct State {
        var histories: [History]
    }

    enum Action {
        case fetchHistories
    }

    enum Mutation {
        case setHistories([History])
    }

    let initialState: State
    private let historyUseCase: HistoryUseCase

    init(historyUseCase: HistoryUseCase = DefaultHistoryUseCase()) {
        self.initialState = State(histories: [])
        
        self.historyUseCase = historyUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchHistories:
            return historyUseCase.fetchHistries()
                .asObservable()
                .map { .setHistories($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setHistories(let histories):
            newState.histories = histories
        }
        return newState
    }
}
