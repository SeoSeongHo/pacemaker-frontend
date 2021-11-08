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
import RxKeyboard

class LoginViewController: UIViewController, View {
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel = UILabel().then {
        $0.text = "Pacemaker"
        $0.font = .systemFont(ofSize: 40, weight: .bold)
    }

    private let emailTextField = InputField().then {
        $0.textField.placeholder = "email"
        $0.textField.keyboardType = .emailAddress
        $0.titleLabel.text = "email"
    }

    private let passwordTextField = InputField().then {
        $0.textField.placeholder = "password"
        $0.titleLabel.text = "password"
        $0.textField.isSecureTextEntry = true
    }

    private let loginButton = UIButton().then {
        $0.setTitle("Sign in", for: .normal)
        $0.backgroundColor = .gray
        $0.roundCorner(7)
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

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(emailTextField)
        bottomStackView.addArrangedSubview(passwordTextField)
        bottomStackView.addArrangedSubview(loginButton)
        bottomStackView.addArrangedSubview(signupButton)

        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.centerX.equalToSuperview()
        }

        bottomStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(150)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(50)
        }

        loginButton.snp.makeConstraints { make in
            make.height.equalTo(46)
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
                let viewController = SignupViewController(reactor: SignupViewReactor())
                self?.present(viewController, animated: true)
            })
            .disposed(by: disposeBag)

        emailTextField.textField.rx.text
            .distinctUntilChanged()
            .map { .setEmail($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        passwordTextField.textField.rx.text
            .distinctUntilChanged()
            .map { .setPassword($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        loginButton.rx.tap.map { _ in .signin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.compactMap(\.user)
            .take(1)
            .do(onNext: { _ in
                Toaster.shared.setLoading(true)
            })
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { user in
                Toaster.shared.setLoading(false)
                let navigationController = UINavigationController(rootViewController: MatchViewController(reactor: MatchViewReactor()))
                UIApplication.shared.keyWindow?.rootViewController = navigationController
            })
            .disposed(by: disposeBag)

        RxKeyboard.instance.visibleHeight
            .distinctUntilChanged()
            .drive(onNext: { [weak self] height in
                self?.scrollView.snp.updateConstraints { make in
                    make.bottom.equalToSuperview().inset(height)
                }
            })
            .disposed(by: disposeBag)
    }
}
