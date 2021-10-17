//
//  LoginViewController.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/10/17.
//

import UIKit
import RxCocoa
import RxSwift
import ReactorKit
import Then
import SnapKit

class LoginViewController: UIViewController, View {

    private let titleLabel = UILabel().then {
        $0.text = "Pacemaker"
        $0.font = .systemFont(ofSize: 40, weight: .bold)
    }

    private let emailTextField = UITextField().then {
        $0.placeholder = "email"
        $0.keyboardType = .emailAddress
        $0.layer.borderColor = UIColor.gray.cgColor
        $0.layer.borderWidth = 1
    }

    private let passwordTextField = UITextField().then {
        $0.placeholder = "password"
        $0.isSecureTextEntry = true
        $0.layer.borderColor = UIColor.gray.cgColor
        $0.layer.borderWidth = 1
    }

    private let loginButton = UIButton().then {
        $0.setTitle("Sign in", for: .normal)
        $0.backgroundColor = .gray
    }

    private let signupButton = UIButton().then {
        $0.setTitle("sign up", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
    }

    private let bottomStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .fill
    }

    var disposeBag = DisposeBag()

    private func configure() {
        view.backgroundColor = .white

        view.addSubview(titleLabel)
        view.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(emailTextField)
        bottomStackView.addArrangedSubview(passwordTextField)
        bottomStackView.addArrangedSubview(loginButton)
        bottomStackView.addArrangedSubview(signupButton)

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }

        bottomStackView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
        }
    }

    init(reactor: LoginViewReactor) {
        super.init(nibName: nil, bundle: nil)

        defer { self.reactor = reactor }

        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(reactor: LoginViewReactor) {
        signupButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let viewController = SignupViewController()
                self?.present(viewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
