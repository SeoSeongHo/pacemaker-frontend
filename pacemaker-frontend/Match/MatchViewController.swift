//
//  MatchViewController.swift
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

class MatchViewController: UIViewController, View {
    private let matchButton = UIButton().then {
        $0.setTitle("Match Start", for: .normal)
        $0.backgroundColor = .gray
        $0.roundCorner(7)
        $0.titleLabel?.font = .systemFont(ofSize: 40, weight: .bold)
    }
    
    private let distanceLabel = InputField().then {
        $0.titleLabel.text = "Distance"
        $0.textField.text = ""
        $0.textField.isUserInteractionEnabled = false
    }
    
    private let runnerLabel = InputField().then {
        $0.titleLabel.text = "Runners"
        $0.textField.text = ""
        $0.textField.isUserInteractionEnabled = false
    }
    
    private let editButton = UIButton().then {
        $0.setTitle("Edit", for: .normal)
        $0.backgroundColor = .gray
        $0.roundCorner(7)
    }

    private let bottomStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .fill
    }
    
    var disposeBag = DisposeBag()
    
    private func configure() {
        view.backgroundColor = .white
        
        view.addSubview(matchButton)
        view.addSubview(bottomStackView)
        view.addSubview(editButton)
        
        bottomStackView.addArrangedSubview(distanceLabel)
        bottomStackView.addArrangedSubview(runnerLabel)
        
        matchButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.centerY.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(69)
        }
        
        editButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(75)
            make.height.equalTo(46)
        }
        
        bottomStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalTo(editButton.snp.top).offset(-25)
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
        matchButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                // TODO: Run view
            })
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let viewController = MatchEditViewController(reactor: reactor)
                let navigationController = UINavigationController(rootViewController: viewController)
                self?.present(navigationController, animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map(\.distance)
            .subscribe(onNext: { distance in
                self.distanceLabel.textField.text = distance.rawValue
            })
            .disposed(by: disposeBag)
        
        reactor.state.map(\.runner)
            .subscribe(onNext: { runner in
                self.runnerLabel.textField.text = runner.rawValue
            })
            .disposed(by: disposeBag)
    }
}
