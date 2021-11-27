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
    private let preMatchContentView = UIView().then {
        $0.isHidden = false
    }
    private let findingMatchContentView = UIView().then {
        $0.isHidden = true
    }
    
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

    private let findingTitleLabel = UILabel().then {
        $0.text = "Finding\nPacemakers..."
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 40, weight: .bold)
    }
    
    private let loadingActivityIndicator = UIActivityIndicatorView().then {
        $0.style = .large
    }
    
    private let cancelButton = UIButton().then {
        $0.setTitle("Cancel", for: .normal)
        $0.backgroundColor = .gray
        $0.roundCorner(7)
    }
    
    var disposeBag = DisposeBag()
    
    private func configure() {
        view.backgroundColor = .white
        
        view.addSubview(preMatchContentView)
        view.addSubview(findingMatchContentView)
        
        preMatchContentView.addSubview(matchButton)
        preMatchContentView.addSubview(bottomStackView)
        preMatchContentView.addSubview(editButton)
        
        findingMatchContentView.addSubview(findingTitleLabel)
        findingMatchContentView.addSubview(loadingActivityIndicator)
        findingMatchContentView.addSubview(cancelButton)
        
        preMatchContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        findingMatchContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
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
        
        findingTitleLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.centerY.equalToSuperview().multipliedBy(0.6)
        }
        
        loadingActivityIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(75)
            make.height.equalTo(46)
        }
    }
    
    init(reactor: MatchViewReactor) {
        super.init(nibName: nil, bundle: nil)

        defer { self.reactor = reactor }

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound],
            completionHandler: { _, _ in }
        )

        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: MatchViewReactor) {
        matchButton.rx.tap
            .do(onNext: { [weak self] _ in
                self?.preMatchContentView.isHidden = true
                self?.findingMatchContentView.isHidden = false
                self?.loadingActivityIndicator.startAnimating()
            })
            .delay(.seconds(2), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                let viewController = RunningViewController(reactor: RunningViewReactor())
                let navigationController = UINavigationController(rootViewController: viewController).then {
                    $0.modalPresentationStyle = .fullScreen
                }
                self?.present(navigationController, animated: true)

                self?.preMatchContentView.isHidden = false
                self?.findingMatchContentView.isHidden = true
                self?.loadingActivityIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let viewController = MatchEditViewController(reactor: reactor)
                let navigationController = UINavigationController(rootViewController: viewController)
                self?.present(navigationController, animated: true)
            })
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.preMatchContentView.isHidden = false
                self?.findingMatchContentView.isHidden = true
                self?.loadingActivityIndicator.stopAnimating()
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
