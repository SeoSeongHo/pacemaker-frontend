//
//  MatchViewReactor.swift
//  pacemaker-frontend
//
//  Created by 이지원 on 2021/11/01.
//

import ReactorKit
import RxSwift
import RxCocoa

final class MatchViewReactor: Reactor {
    enum Status {
        case idle
        case finding
        case ready
    }
    struct State {
        var distance: Distance
        var runner: Runner
        var status: Status = .idle
    }

    let matchPublisher = PublishRelay<Match>()

    enum Action {
        case match
        case cancel
        case start
        case setDistance(Distance)
        case setRunner(Runner)
    }

    enum Mutation {
        case setDistance(Distance)
        case setRunner(Runner)
        case setStatus(Status)
    }

    let initialState: State
    private let matchUseCase: MatchUseCase

    init(matchUseCase: MatchUseCase = DefaultMatchUseCase()) {
        self.initialState = State(distance: Distance.short, runner: Runner.two)
        
        self.matchUseCase = matchUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .match:
            return .concat(
                .just(.setStatus(.finding)),
                pollMatch()
            )
        case .cancel:
            return .concat(
                .just(.setStatus(.idle)),
                matchUseCase.cancel(
                    distance: currentState.distance.rawValue,
                    memberCount: currentState.runner.rawValue
                ).asObservable().flatMap { _ in Observable<Mutation>.empty() }
            )

        case .start:
            return .just(.setStatus(.idle))

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
        case .setStatus(let status):
            newState.status = status
        }
        return newState
    }

    func pollMatch() -> Observable<Mutation> {
        return matchUseCase.start(
            distance: currentState.distance.rawValue,
            memberCount: currentState.runner.rawValue
        )
            .asObservable()
            .flatMap { [weak self] match -> Observable<Mutation> in
                guard let self = self else { return .empty() }
                if match.status == .MATCHING_COMPLETE {
                    self.matchPublisher.accept(match)
                    return .just(.setStatus(.ready))
                } else if match.status == .MATCHING, self.currentState.status == .finding {
                    return Observable<Void>.just(())
                        .delay(.seconds(3), scheduler: MainScheduler.asyncInstance)
                        .flatMap { [weak self] _ -> Observable<Mutation> in
                            guard let self = self else { return .empty() }
                            return self.pollMatch()
                        }
                }
                return .just(.setStatus(.idle))
            }
            .catch {
                Toaster.shared.showToast(.error($0.localizedDescription))
                return .just(.setStatus(.idle))
            }
    }
}
