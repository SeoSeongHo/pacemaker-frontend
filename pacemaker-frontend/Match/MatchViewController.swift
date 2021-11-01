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
    }
    
    private var distanceLabel = UILabel().then {
        $0.text = "Distance : "
        $0.font = .systemFont(ofSize: 20, weight: .bold)
    }

    private var runnerLabel = UILabel().then {
        $0.text = "Runners : "
        $0.font = .systemFont(ofSize: 20, weight: .bold)
    }
    
    private let editButton = UIButton().then {
        $0.setTitle("Edit", for: .normal)
        $0.backgroundColor = .gray
        $0.roundCorner(7)
    }

    private let middleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .fill
    }
    
    var disposeBag = DisposeBag()
    
    private func configure() {
        view.backgroundColor = .white
        
        view.addSubview(matchButton)
        view.addSubview(middleStackView)
        view.addSubview(editButton)
        
        middleStackView.addArrangedSubview(distanceLabel)
        middleStackView.addArrangedSubview(runnerLabel)
        
        matchButton.snp.makeConstraints { make in
            make.left.top.right.equalTo(view.safeAreaLayoutGuide).inset(50)
        }
        
        middleStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }
        
        editButton.snp.makeConstraints { make in
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
        matchButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                // TODO: Run view
            })
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let viewController = MatchEditViewController(reactor: MatchViewReactor())
                self?.present(viewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap(\.distance)
            .take(1)
            .subscribe(onNext: { distance in
                self.distanceLabel.text = distance
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap(\.runner)
            .take(1)
            .subscribe(onNext: { runner in
                self.runnerLabel.text = runner
            })
            .disposed(by: disposeBag)
    }
}
