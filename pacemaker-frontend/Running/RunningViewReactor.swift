//
//  RunningViewReactor.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/11/08.
//

import ReactorKit
import RxSwift
import CoreLocation

final class RunningViewReactor: Reactor {
    struct State {
        var locations: [CLLocation] = []
        var distance: CLLocationDistance = 0
        var speed: CLLocationSpeed = 0
        var matchUser: [MatchUser]
    }

    enum Action {
        case start
        case finish
    }

    enum Mutation {
        case setLocation(CLLocation?)
        case setMatchUser([MatchUser])
    }

    let donePublisher = PublishSubject<Void>()
    let initialState: State
    private let locationManager: LocationManager
    private let notificationManager: NotificationManager
    private let matchUseCase: MatchUseCase
    let match: Match
    let distance: Int

    init(
        distance: Int,
        match: Match,
        locationManager: LocationManager = DefaultLocationManager.shared,
        notificationManager: NotificationManager = DefaultNotificationManager(),
        matchUseCase: MatchUseCase = DefaultMatchUseCase()
    ) {
        self.distance = distance
        self.match = match
        self.initialState = State(matchUser: match.users)
        self.locationManager = locationManager
        self.notificationManager = notificationManager
        self.matchUseCase = matchUseCase
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .start:
            notificationManager.start()
            locationManager.start()
            return .merge(
                locationManager.currentLocation
                    .skip(.seconds(1), scheduler: MainScheduler.asyncInstance)
                    .map { .setLocation($0) },
                pollMatch()
            )
        case .finish:
            notificationManager.finish()
            locationManager.stop()
            return .empty()
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLocation(let location):
            if let location = location {
                newState.speed = location.speed
                if let prevLocation = newState.locations.last {
                    newState.distance += location.distance(from: prevLocation)
                }
                newState.locations.append(location)
            }
        case .setMatchUser(let users):
            newState.matchUser = users
        }
        return newState
    }

    func notification(for event: MatchEvent) {
        switch event {
        case .LEFT_100M:
            notificationManager.left100()
        case .LEFT_50M:
            notificationManager.left50()
        case .OVERTAKEN:
            notificationManager.overtaken()
        case .OVERTAKING:
            notificationManager.overtaking()
        case .FINISH:
            notificationManager.finish()
        case .FINISH_OTHER:
            notificationManager.finishOther()
        case .DONE:
            notificationManager.done()
        case .FIRST_PLACE:
            notificationManager.firstPlace()
        case .NONE:
            break
        }
    }

    func pollMatch() -> Observable<Mutation> {
        return matchUseCase.sendMatchInfo(
            userMatchId: match.users.first?.userMatchId ?? -1,
            distance: currentState.distance,
            currentSpeed: currentState.speed
        )
            .asObservable()
            .flatMap { [weak self] match -> Observable<Mutation> in
                guard let self = self else { return .empty() }
                if let event = match.alarmCategory {
                    self.notification(for: event)
                    if event == .DONE {
                        self.donePublisher.onNext(())
                        self.locationManager.stop()
                        return .just(.setMatchUser(match.matchUsers))
                    }
                }
                return .concat(
                    .just(.setMatchUser(match.matchUsers)),
                    self.pollMatch()
                )
            }
    }

    deinit {
        locationManager.stop()
    }
}

