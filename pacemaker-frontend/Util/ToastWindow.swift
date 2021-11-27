//
//  ToastWindow.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/11/01.
//

import Foundation
import RxSwift

final class ToastWindow: UIWindow {
    fileprivate static let horizontalPadding: CGFloat = 50
    fileprivate static let topPadding: CGFloat = 100
    fileprivate static let bottomPadding: CGFloat = 70

    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)

        isUserInteractionEnabled = false

        backgroundColor = UIColor.clear
        windowLevel = UIWindow.Level(rawValue: 1001)
        rootViewController = Toaster.shared
        isHidden = false
    }

    @available(iOS 13.0, *)
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)

        isUserInteractionEnabled = false

        backgroundColor = UIColor.clear
        windowLevel = UIWindow.Level(rawValue: 1001)
        rootViewController = Toaster.shared
        isHidden = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol Toast {
    func showToast(_ type: ToastView.ToastType)
    func setLoading(_ loading: Bool)
}

final class Toaster: UIViewController, Toast {

    static let shared = Toaster()

    private let toastStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .fill
    }

    private var loadingCount: Int = 0

    private let loadingView = UIActivityIndicatorView(style: .large)

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.isUserInteractionEnabled = false

        view.addSubview(loadingView)
        view.addSubview(toastStackView)

        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(40)
        }

        toastStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(18)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(70)
        }

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                guard let ss = self else { return }
                if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardHeight = keyboardFrame.cgRectValue.height
                    ss.toastStackView.snp.updateConstraints { make in
                        make.bottom.equalTo(ss.view.safeAreaLayoutGuide).inset(keyboardHeight + 20 - ss.view.safeAreaInsets.bottom)
                    }
                }
            })
            .disposed(by: disposeBag)

        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] notification in
                guard let ss = self else { return }
                ss.toastStackView.snp.updateConstraints { make in
                    make.bottom.equalTo(ss.view.safeAreaLayoutGuide).inset(70)
                }
            })
            .disposed(by: disposeBag)

    }

    func showToast(_ type: ToastView.ToastType) {
        let view = ToastView(type: type)

        if let toastView = toastStackView.arrangedSubviews.first(where: { ($0 as? ToastView)?.type == type }) {
            UIView.animate(withDuration: 0.1) {
                toastView.alpha = 0
            } completion: { [weak self] _ in
                self?.toastStackView.removeArrangedSubview(toastView)
                toastView.removeFromSuperview()
                view.alpha = 0
                self?.toastStackView.addArrangedSubview(view)
                UIView.animate(withDuration: 0.1) {
                    view.alpha = 1
                }
            }
        } else {
            toastStackView.addArrangedSubview(view)
        }


        Single.just(Void())
            .delay(.seconds(2), scheduler: MainScheduler.asyncInstance)
            .subscribe(onSuccess: { [weak self] _ in
                UIView.animate(withDuration: 0.5) {
                    view.alpha = 0
                } completion: { [weak self] _ in
                    self?.toastStackView.removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
            })
            .disposed(by: view.disposeBag)
    }

    func setLoading(_ loading: Bool) {
        if loading {
            loadingCount += 1
        } else {
            loadingCount -= 1
        }

        guard loadingCount >= 0 else {
            loadingCount = 0
            setLoadingUI(false)
            return
        }

        setLoadingUI(loadingCount > 0)
    }

    private func setLoadingUI(_ loading: Bool) {
        if loading {
            view.window?.isUserInteractionEnabled = true
            loadingView.startAnimating()
            loadingView.alpha = 1
        } else {
            view.window?.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.loadingView.alpha = 0
                self?.view.layoutIfNeeded()
            } completion: { [weak self] _ in
                self?.loadingView.stopAnimating()
            }
        }
    }
}

final class ToastView: UIView {

    enum ToastType: Equatable {
        case error(String)
        case warning(String)
        case success(String)

        var image: UIImage? {
            switch self {
            case .error:
                return UIImage(systemName: "xmark.octagon")
            case .warning:
                return UIImage(systemName: "exclamationmark.triangle")
            case .success:
                return UIImage(systemName: "checkmark.circle")
            }
        }

        var message: String {
            switch self {
            case .error(let message):
                return message
            case .warning(let message):
                return message
            case .success(let message):
                return message
            }
        }

        static var generalError: ToastType {
            return .error("요청에 실패했습니다. 인터넷 연결 상태를 확인하세요.")
        }
    }

    private let messageLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 12, weight: .medium)
    }

    private let imageView = UIImageView()

    let type: ToastType
    let disposeBag = DisposeBag()

    init(type: ToastType) {
        self.type = type
        super.init(frame: .zero)

        messageLabel.text = type.message
        imageView.image = type.image
        backgroundColor = .white
        roundCorner(7, color: .primary)
        addSubview(imageView)
        addSubview(messageLabel)

        imageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(18)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview().inset(17)
            make.left.equalTo(imageView.snp.right).offset(13)
        }


    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class ConfirmView: UIView {

    private let titleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 17, weight: .medium)
    }

    private let descLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.textColor = .white
        $0.font = .systemFont(ofSize: 12, weight: .medium)
    }

    private let labelView = UIView()

    private let cancelButton = UIButton().then {
        $0.setTitle("취소", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16)
    }

    private let confirmButton = UIButton().then {
        $0.setTitle("확인", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
    }

    let disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)

        backgroundColor = .lightGray

        addSubview(labelView)
        labelView.addSubview(titleLabel)
        labelView.addSubview(descLabel)
        roundCorner(7)
        addSubview(cancelButton)
        addSubview(confirmButton)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

