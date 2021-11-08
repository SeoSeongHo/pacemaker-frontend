//
//  RunningMapViewReactor.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/11/08.
//

import ReactorKit
import RxSwift
import CoreLocation

final class RunningMapViewReactor: Reactor {
    struct State {
        var location: CLLocation?
    }

    enum Action {
        case start
    }

    enum Mutation {
        case setLocation(CLLocation?)
    }

    let initialState: State
    private let locationManager: LocationManager

    init(locationManager: LocationManager = DefaultLocationManager.shared) {
        self.initialState = State()
        self.locationManager = locationManager
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .start:
            return locationManager.currentLocation.map { .setLocation($0) }
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLocation(let location):
            newState.location = location
        }
        return newState
    }
}

