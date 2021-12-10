//
//  HistoryDetailViewController.swift
//  pacemaker-frontend
//
//  Created by 이지원 on 2021/11/27.
//

import UIKit
import ReactorKit
import RxSwift
import SwiftUI

class HistoryDetailViewController: UIViewController {
    private let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: nil, action: nil).then {
        $0.tintColor = .black
    }

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .fill
    }

    private let distanceLabel = InputField().then {
        $0.titleLabel.text = "Distance"
        $0.textField.text = ""
        $0.textField.isUserInteractionEnabled = false
    }

    private let rankLabel = InputField().then {
        $0.titleLabel.text = "Rank"
        $0.textField.text = ""
        $0.textField.isUserInteractionEnabled = false
    }

    private let timeLabel = InputField().then {
        $0.titleLabel.text = "Time"
        $0.textField.text = ""
        $0.textField.isUserInteractionEnabled = false
    }
    
    var disposeBag = DisposeBag()
    
    private func configure() {
        navigationItem.leftBarButtonItem = backButton
        navigationItem.title = "Result"
        view.backgroundColor = .white
        
        view.addSubview(stackView)
        stackView.addArrangedSubview(distanceLabel)
        stackView.addArrangedSubview(rankLabel)
        stackView.addArrangedSubview(timeLabel)

        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
    }
    
    init(history : History) {
        super.init(nibName: nil, bundle: nil)
        
        configure()
        
        setValue(history: history)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setValue(history: History) {
        distanceLabel.textField.text = "\(history.totalDistance)m"
        timeLabel.textField.text = "\(history.totalTime)min"
        rankLabel.textField.text = "\(history.rank) / \(history.totalMembers)"
    }
}
