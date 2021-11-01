//
//  InputField.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/11/01.
//

import UIKit
import RxSwift
import RxCocoa

class InputField: UIView {
    let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .bold)
    }
    let errorLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.adjustsFontSizeToFitWidth = true
        $0.textAlignment = .right
        $0.isHidden = true
    }
    let textField = PaddingTextField(padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)).then {
        $0.font = .systemFont(ofSize: 14)
        $0.roundCorner(7, color: .lightGray)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        addSubview(titleLabel)
        addSubview(textField)
        addSubview(errorLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
        }

        errorLabel.snp.makeConstraints { make in
            make.bottom.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right).offset(10)
            make.right.equalToSuperview()
        }

        textField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(7)
            make.left.right.equalToSuperview()
            make.height.equalTo(46)
            make.bottom.equalToSuperview()
        }
    }

    fileprivate func setError(_ error: Bool) {
        if error {
            textField.roundCorner(7, color: .red)
            errorLabel.isHidden = false
        } else {
            textField.roundCorner(7, color: .gray)
            errorLabel.isHidden = true
        }
    }
}

extension Reactive where Base: InputField {
    var error: Binder<Bool> {
        return Binder(self.base) { base, error in
            base.setError(error)
        }
    }
}

final class PaddingTextField: UITextField {

    let padding: UIEdgeInsets

    init(padding: UIEdgeInsets) {
        self.padding = padding

        super.init(frame: .zero)
        clearButtonMode = .whileEditing
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

