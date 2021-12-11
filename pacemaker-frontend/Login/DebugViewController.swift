//
//  DebugViewController.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/12/11.
//

import UIKit
import ReactorKit
import RxSwift
import Charts

class DebugViewController: UIViewController {
    private let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: nil, action: nil).then {
        $0.tintColor = .black
    }

    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .fill
    }

    private let saveButton = UIButton().then {
        $0.setTitle("Save", for: .normal)
        $0.backgroundColor = .primary
        $0.roundCorner(7)
    }

    private let matchButton = UIButton().then {
        $0.setTitle("Go to MatchViewController", for: .normal)
        $0.backgroundColor = .primary
        $0.roundCorner(7)
    }

    private let baseURLInput = InputField().then {
        $0.titleLabel.text = "Backend base url"
        $0.textField.text = DefaultRequestManager.shared.baseURL
    }

    private let matchPollingInterval = InputField().then {
        $0.titleLabel.text = "Match polling interval"
        $0.textField.text = String(DefaultMatchUseCase.shared.matchPollingInterval)
        $0.textField.keyboardType = .numberPad
    }

    var disposeBag = DisposeBag()

    private func configure() {
        navigationItem.leftBarButtonItem = backButton
        navigationItem.title = "Result"
        view.backgroundColor = .white

        view.addSubview(stackView)
        stackView.addArrangedSubview(baseURLInput)
        stackView.addArrangedSubview(matchPollingInterval)
        stackView.addArrangedSubview(saveButton)
        stackView.addArrangedSubview(matchButton)

        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
    }

    init() {
        super.init(nibName: nil, bundle: nil)

        configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      let url = self.baseURLInput.textField.text,
                      let intervalText = self.matchPollingInterval.textField.text,
                      let interval = Int(intervalText) else { return }

                DefaultRequestManager.shared.baseURL = url
                DefaultMatchUseCase.shared.matchPollingInterval = interval
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        matchButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                self.dismiss(animated: true) {
                    let viewController = TabBarController()
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                }
            })
            .disposed(by: disposeBag)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
