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
    }

    enum Action {
        case start
        case finish
    }

    enum Mutation {
        case setLocation(CLLocation?)
    }

    let initialState: State
    private let locationManager: LocationManager
    private let notificationManager: NotificationManager
    let match: Match
    let distance: Int

    init(
        distance: Int,
        match: Match,
        locationManager: LocationManager = DefaultLocationManager.shared,
        notificationManager: NotificationManager = DefaultNotificationManager()
    ) {
        self.distance = distance
        self.match = match
        self.initialState = State()
        self.locationManager = locationManager
        self.notificationManager = notificationManager
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .start:
            notificationManager.start()
            locationManager.start()
            return locationManager.currentLocation
                .skip(.seconds(1), scheduler: MainScheduler.asyncInstance)
                .map { .setLocation($0) }
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
        }
    }
}

