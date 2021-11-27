//
//  RunningMapViewController.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/11/08.
//

import UIKit
import RxCocoa
import RxSwift
import ReactorKit
import Then
import SnapKit
import RxKeyboard
import MapKit

class RunningMapViewController: UIViewController, View {
    class MyPointAnnotation : MKPointAnnotation {
        var isStartingPoint = false
        var isEndingPoint = false
    }

    private let mapView = MKMapView().then {
        $0.showsUserLocation = true
    }
    private let infoView = UIView().then {
        $0.backgroundColor = .white
        $0.roundCorner()
        $0.applyShadow()
    }

    private let backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        $0.applyShadow()
        $0.tintColor = .black
        $0.backgroundColor = .white
        $0.roundCorner(20)
        $0.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
    }

    private let infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
    }

    private let distanceLabel = InputField().then {
        $0.titleLabel.text = "Distance"
        $0.textField.text = "100/1000m"
        $0.textField.isUserInteractionEnabled = false
    }
    private let speedLabel = InputField().then {
        $0.titleLabel.text = "Speed"
        $0.textField.text = "4.3km/h"
        $0.textField.isUserInteractionEnabled = false
    }

    var disposeBag = DisposeBag()
    private var route: MKOverlay?

    private func configure() {
        mapView.delegate = self
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        view.backgroundColor = .white

        view.addSubview(mapView)
        view.addSubview(infoView)
        infoView.addSubview(infoStackView)
        infoStackView.addArrangedSubview(distanceLabel)
        infoStackView.addArrangedSubview(speedLabel)

        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        infoView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
        }

        infoStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    init(reactor: RunningViewReactor) {
        super.init(nibName: nil, bundle: nil)

        defer { self.reactor = reactor }

        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(reactor: RunningViewReactor) {
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        reactor.state.map(\.distance)
            .distinctUntilChanged()
            .subscribe(onNext: { [distanceLabel] distance in
                distanceLabel.textField.text = "\(Int(distance))/1000m"
            })
            .disposed(by: disposeBag)

        reactor.state.map(\.locations.last)
            .distinctUntilChanged()
            .subscribe(onNext: { [mapView, speedLabel] location in
                if let userLocation = location?.coordinate {
                    let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
                    mapView.setRegion(viewRegion, animated: true)
                }

                speedLabel.textField.text = location.map { "\($0.speed)m/s" }
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.locations.map { $0.coordinate } }
            .subscribe(onNext: { [weak self] coordinates in
                let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                if let prevRoute = self?.route {
                    self?.mapView.removeOverlay(prevRoute)
                }
                self?.route = polyline
                self?.mapView.addOverlay(polyline)
            })
            .disposed(by: disposeBag)
    }
}

extension RunningMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }

        return MKAnnotationView()
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.blue.withAlphaComponent(0.9)
            renderer.lineWidth = 7
            return renderer
        }

        return MKOverlayRenderer()
    }
}
