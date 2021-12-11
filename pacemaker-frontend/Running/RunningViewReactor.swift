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
        var finishedUser: [MatchUser] = []
        var isFinished = false
        var myPlace: Int = 1
    }

    enum Action {
        case start
        case finish
    }

    enum Mutation {
        case setLocation(CLLocation?)
        case setMatchUser([MatchUser])
    }

    let donePublisher = PublishSubject<History>()
    let initialState: State
    private let locationManager: LocationManager
    private let notificationManager: NotificationManager
    private let matchUseCase: MatchUseCase
    private let historyUseCase: HistoryUseCase
    let match: Match
    let distance: Int
    var count = 0

    init(
        distance: Int,
        match: Match,
        locationManager: LocationManager = DefaultLocationManager.shared,
        notificationManager: NotificationManager = DefaultNotificationManager(),
        historyUseCase: HistoryUseCase = DefaultHistoryUseCase(),
        matchUseCase: MatchUseCase = DefaultMatchUseCase.shared
    ) {
        self.historyUseCase = historyUseCase
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
            // 임시 구현.. TODO: reduce에서 사이드이펙트를 발생시키지 않도록
            let me = users[0]
            newState.matchUser = users
            newState.isFinished = me.currentDistance >= Double(distance)
            newState.myPlace = users
                .sorted(by: { $0.currentDistance > $1.currentDistance  })
                .firstIndex(where: { $0.id == me.id })
                .map { $0 + 1 } ?? 1
            newState.finishedUser = users.filter {
                $0.id != me.id && $0.currentDistance >= Double(distance)
            }
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
            locationManager.stop()
            notificationManager.finish()
        case .FINISH_OTHER:
            notificationManager.finishOther()
        case .DONE:
            locationManager.stop()
            notificationManager.done()
        case .FIRST_PLACE:
            notificationManager.firstPlace()
        case .NONE:
            break
        }
    }

    func pollMatch() -> Observable<Mutation> {
        count += 1
        return matchUseCase.sendMatchInfo(
            userMatchId: match.users.first?.userMatchId ?? -1,
            distance: currentState.distance,
            currentSpeed: max(0, currentState.speed),
            count: count
        )
            .asObservable()
            .flatMap { [weak self, matchUseCase] match -> Observable<Mutation> in
                guard let self = self else { return .empty() }
                if let event = match.alarmCategory {
                    if event == .DONE {
                        _ = self.historyUseCase.getHistory(userMatchId: self.match.users[0].userMatchId)
                            .asObservable()
                            .bind(to: self.donePublisher)

                        self.locationManager.stop()
                        return .just(.setMatchUser(match.matchUsers))
                    }
                }
                return .concat(
                    .just(.setMatchUser(match.matchUsers)),
                    Observable<Void>.just(())
                        .delay(.seconds(matchUseCase.matchPollingInterval), scheduler: MainScheduler.instance)
                        .flatMap { [weak self] _ -> Observable<Mutation> in
                            guard let self = self else { return .empty() }
                            return self.pollMatch()
                        }
                )
            }
    }

    deinit {
        locationManager.stop()
    }
}

