//
//  LocationManager.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/11/08.
//

import CoreLocation
import RxSwift
import RxCocoa

protocol LocationManager {
    func getCurrentCoord() -> CLLocationCoordinate2D?
    var isLocationEnabled: Bool { get }
    var currentLocation: Observable<CLLocation?> { get }
}

final class DefaultLocationManager: NSObject, LocationManager, CLLocationManagerDelegate {
    static let shared = DefaultLocationManager()
    private var locationManager: CLLocationManager!
    private let myLocation = BehaviorRelay<CLLocation?>(value: nil)
    var isLocationEnabled: Bool {
        return ![CLAuthorizationStatus.denied, CLAuthorizationStatus.notDetermined]
            .contains(locationManager.authorizationStatus)
    }

    var currentLocation: Observable<CLLocation?> {
        myLocation.asObservable()
    }

    override init() {
        super.init()
        self.locationManager = CLLocationManager.init()
        self.locationManager.delegate = self
        locationManager.startUpdatingLocation()
        let authorizationStatus = locationManager.authorizationStatus
        if authorizationStatus == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }

    func getCurrentCoord() -> CLLocationCoordinate2D? {
        locationManager.startUpdatingLocation()
        return myLocation.value.map { $0.coordinate }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        myLocation.accept(locations.last!)
    }
}


