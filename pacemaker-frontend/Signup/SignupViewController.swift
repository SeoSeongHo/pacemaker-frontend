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
    
    private let signupButton = UIButton().then {
        $0.setTitle("Sign up", for: .normal)
        $0.backgroundColor = .gray
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
            make.left.right.top.equalTo(view.safeAreaLayoutGuide).inset(50)
        }
        
        signupButton.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
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
    }
}
