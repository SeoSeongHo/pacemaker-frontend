//
//  SignupViewController.swift
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

class SignupViewController: UIViewController, View {
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
    
    private let signupButton = UIButton().then {
        $0.setTitle("Sign up", for: .normal)
        $0.backgroundColor = .gray
        $0.roundCorner(7)
    }
    
    private let topStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 20
        $0.alignment = .fill
    }
    
    var disposeBag = DisposeBag()
    
    private func configure() {
        view.backgroundColor = .white
            
        view.addSubview(topStackView)
        topStackView.addArrangedSubview(emailTextField)
        topStackView.addArrangedSubview(passwordTextField)
        
        view.addSubview(signupButton)
        
        topStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(100)
            make.left.right.equalToSuperview().inset(50)
        }
        
        signupButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(75)
            make.height.equalTo(46)
        }
    }
    
    init(reactor: SignupViewReactor) {
        super.init(nibName: nil, bundle: nil)

        defer { self.reactor = reactor }

        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: SignupViewReactor) {
        signupButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
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

        reactor.state.compactMap(\.user)
            .take(1)
            .subscribe(onNext: { user in
                // TODO: user 저장, main view로 보냄
            })
            .disposed(by: disposeBag)
    }
}
