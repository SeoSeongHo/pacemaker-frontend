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

class MatchEditViewController: UIViewController, View {
    
    private let distanceLabel = UILabel().then {
        $0.text = "Distance"
        $0.font = .systemFont(ofSize: 20, weight: .bold)
    }
    
    private let distanceSegementedControl = UISegmentedControl(items: ["1000m", "1500m", "2000m"])

    private let runnerTextField = InputField().then {
        $0.textField.placeholder = "runner"
        $0.titleLabel.text = "Number of runners"
    }
    
    private let confirmButton = UIButton().then {
        $0.setTitle("Confirm", for: .normal)
        $0.backgroundColor = .gray
        $0.roundCorner(7)
    }
    
    private let distanceStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 1
        $0.alignment = .fill
    }
    
    private let middleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .fill
    }
    
    var disposeBag = DisposeBag()
    
    private func configure() {
        view.backgroundColor = .white
        
        view.addSubview(middleStackView)
        view.addSubview(confirmButton)
        
        distanceStackView.addArrangedSubview(distanceLabel)
        distanceStackView.addArrangedSubview(distanceSegementedControl)
        middleStackView.addArrangedSubview(distanceStackView)
        middleStackView.addArrangedSubview(runnerTextField)
        
        middleStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }
        
        confirmButton.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(50)
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
        confirmButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let viewController = MatchViewController(reactor: MatchViewReactor())
                self?.present(viewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        distanceSegementedControl.rx.value
            .distinctUntilChanged()
            .map { .setDistance(String($0)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        runnerTextField.textField.rx.text
            .distinctUntilChanged()
            .map { .setRunner($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
}

