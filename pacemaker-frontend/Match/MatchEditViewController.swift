//
//  MatchEditViewController.swift
//  pacemaker-frontend
//
//  Created by 이지원 on 2021/11/01.
//

import UIKit
import RxCocoa
import RxSwift
import ReactorKit
import Then
import SnapKit

enum Distance: Int, CaseIterable {
    case short = 1000
    case middle = 1500
    case long = 2000

    var title: String {
        switch self {
        case .short:
            return "1000m"
        case .middle:
            return "1500m"
        case .long:
            return "2000m"
        }
    }
}

enum Runner: Int, CaseIterable {
    case two = 2
    case three = 3
    case four = 4

    var title: String {
        "\(self.rawValue)"
    }
}

class MatchEditViewController: UIViewController, View {
    private let backButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: nil, action: nil).then {
        $0.tintColor = .black
    }

    private let descriptionLabel = UILabel().then {
        $0.text = "Please select the distance you will run and the number of people.\nAfter a match with anonymous people, it cannot be changed."
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 15, weight: .regular)
    }
    
    private let distanceLabel = UILabel().then {
        $0.text = "Distance"
        $0.font = .systemFont(ofSize: 15, weight: .bold)
    }
    
    private let distanceSegementedControl = UISegmentedControl(items: Distance.allCases.map { $0.rawValue })
    
    private let runnerLabel = UILabel().then {
        $0.text = "Number of runners"
        $0.font = .systemFont(ofSize: 15, weight: .bold)
    }
    
    private let runnerSegementedControl = UISegmentedControl(items: Runner.allCases.map { $0.rawValue })
    
    private let confirmButton = UIButton().then {
        $0.setTitle("Confirm", for: .normal)
        $0.backgroundColor = .primary
        $0.roundCorner(7)
    }
    
    private let distanceStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .fill
    }
    
    private let runnerStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .fill
    }
    
    private let middleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 25
        $0.alignment = .fill
    }
    
    var disposeBag = DisposeBag()
    
    private func configure() {
        navigationItem.leftBarButtonItem = backButton
        navigationItem.title = "Running Environments"
        view.backgroundColor = .white
        
        view.addSubview(descriptionLabel)
        view.addSubview(middleStackView)
        view.addSubview(confirmButton)
        
        distanceStackView.addArrangedSubview(distanceLabel)
        distanceStackView.addArrangedSubview(distanceSegementedControl)
        
        runnerStackView.addArrangedSubview(runnerLabel)
        runnerStackView.addArrangedSubview(runnerSegementedControl)
        
        middleStackView.addArrangedSubview(distanceStackView)
        middleStackView.addArrangedSubview(runnerStackView)
        
        descriptionLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        middleStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalTo(confirmButton.snp.top).offset(-50)
        }
        
        confirmButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(75)
            make.height.equalTo(46)
        }
    }
    
    init(reactor: MatchViewReactor) {
        super.init(nibName: nil, bundle: nil)

        defer { self.reactor = reactor }

        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: MatchViewReactor) {
        reactor.state.map(\.distance)
            .map {
                switch $0 {
                case .short:
                    return 0
                case .middle:
                    return 1
                case .long:
                    return 2
                }
            }
            .bind(to: distanceSegementedControl.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.runner)
            .map {
                switch $0 {
                case .two:
                    return 0
                case .three:
                    return 1
                case .four:
                    return 2
                }
            }
            .bind(to: runnerSegementedControl.rx.selectedSegmentIndex)
            .disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        distanceSegementedControl.rx.selectedSegmentIndex
            .map {
                switch $0 {
                case 0:
                    return .setDistance(Distance.short)
                case 1:
                    return .setDistance(Distance.middle)
                case 2:
                    return .setDistance(Distance.long)
                default:
                    throw DistanceError.undefined
                }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        runnerSegementedControl.rx.selectedSegmentIndex
            .distinctUntilChanged()
            .map {
                switch $0 {
                case -1:
                    return .setRunner(Runner.two)
                case 0:
                    return .setRunner(Runner.two)
                case 1:
                    return .setRunner(Runner.three)
                case 2:
                    return .setRunner(Runner.four)
                default:
                    throw DistanceError.undefined
                }
            }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

enum DistanceError: Error {
    case undefined
}
