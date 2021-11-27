//
//  RunningViewController.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/11/08.
//

import UIKit
import RxCocoa
import RxSwift
import ReactorKit
import Then
import SnapKit
import RxKeyboard
import MapKit
import SDCAlertView

class RunningViewController: UIViewController, View {
    private let mapButton = UIBarButtonItem(
        image: UIImage(systemName: "map"),
        style: .plain,
        target: nil,
        action: nil
    ).then {
        $0.tintColor = .black
    }

    private let progressStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 20
    }

    private let progressView = ProgressView()
    private let progressView1 = ProgressView().then {
        $0.progressLabel.text = "player 1"
    }
    private let progressView2 = ProgressView().then {
        $0.progressLabel.text = "player 2"
    }
    private let progressView3 = ProgressView().then {
        $0.progressLabel.text = "player 3"
    }

    private let giveupButton = UIButton().then {
        $0.setTitle("Give up", for: .normal)
        $0.backgroundColor = .primary
        $0.roundCorner(7)
    }

    private let runningTimeLabel = UILabel().then {
        $0.text = "0:00"
    }
    private let runningTimeTitleLabel = UILabel().then {
        $0.text = "Running Time"
        $0.font = .systemFont(ofSize: 20, weight: .bold)
    }

    var disposeBag = DisposeBag()

    private func configure() {
        navigationItem.title = "Race!"
        navigationItem.rightBarButtonItem = mapButton
        view.backgroundColor = .white

        view.addSubview(giveupButton)
        view.addSubview(runningTimeLabel)
        view.addSubview(runningTimeTitleLabel)
        view.addSubview(progressStackView)
        progressStackView.addArrangedSubview(progressView)
        progressStackView.addArrangedSubview(progressView1)
        progressStackView.addArrangedSubview(progressView2)
        progressStackView.addArrangedSubview(progressView3)

        progressStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(50)
            make.left.right.equalToSuperview().inset(24)
        }

        giveupButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(75)
            make.height.equalTo(46)
        }

        runningTimeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(giveupButton.snp.top).offset(-40)
        }

        runningTimeTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(runningTimeLabel.snp.top).offset(-5)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    init(reactor: RunningViewReactor) {
        super.init(nibName: nil, bundle: nil)

        defer { self.reactor = reactor }

        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(reactor: RunningViewReactor) {
        reactor.action.onNext(.start)
        switch reactor.match.users.count {
        case 3:
            progressView3.isHidden = true
        case 2:
            progressView3.isHidden = true
            progressView2.isHidden = true
        default:
            break
        }

        giveupButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let actions = [
                    AlertAction(title: "cancel", style: .destructive),
                    AlertAction(title: "give up", style: .normal) { _ in
                        self?.dismiss(animated: true, completion: nil)
                    },
                ]

                let vc = AlertController(title: "Warning", message: "Do you really want to give up?", preferredStyle: .alert)

                actions.forEach {
                    vc.addAction($0)
                }

                self?.present(vc, animated: true)
            })
            .disposed(by: disposeBag)

        mapButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let viewController = RunningMapViewController(reactor: reactor)
                self?.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)

        Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] time in
                let minute = time / 60
                let second = time % 60
                self?.runningTimeLabel.text = "\(minute < 10 ? "0\(minute)" : "\(minute)"):\(second < 10 ? "0\(second)" : "\(second)")"

                self?.progressView1.setProgress(Double(time) / 200.0)
                self?.progressView2.setProgress(Double(time) / 170.0)

                if Bool.random() && Bool.random() && Bool.random(), let event = MatchEvent.allCases.randomElement() {
                    reactor.notification(for: event)
                }
            })
            .disposed(by: disposeBag)

        reactor.state.map(\.distance)
            .subscribe(onNext: { [weak self] distance in
                let progress = distance / Double(reactor.distance)
                self?.progressView.setProgress(distance / Double(reactor.distance))
                if progress > 1 {
                    reactor.action.onNext(.finish)
                }
            })
            .disposed(by: disposeBag)
    }
}

class ProgressView: UIView {
    private let progressView = UIView().then {
        $0.roundCorner(2)
        $0.backgroundColor = .lightGray
    }

    private let progressIndicatorView = UIView().then {
        $0.roundCorner(5, color: .black)
        $0.backgroundColor = .white
    }

    let progressLabel = UILabel().then {
        $0.text = "me"
        $0.font = .systemFont(ofSize: 20, weight: .bold)
    }

    private let progressIndicator = UIImageView().then {
        $0.image = UIImage(systemName: "figure.walk")
        $0.tintColor = .black
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(progressView)
        addSubview(progressLabel)
        addSubview(progressIndicatorView)
        progressIndicatorView.addSubview(progressIndicator)

        progressLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }

        progressView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12.5)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(5)
        }

        progressIndicatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(0)
            make.top.equalTo(progressLabel.snp.bottom).offset(30)
            make.size.equalTo(30)
        }

        progressIndicator.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(5)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setProgress(_ progress: Double) {
        let progress = min(progress, 1)
        let inset = (bounds.width - 20) * progress

        progressIndicatorView.snp.updateConstraints { make in
            make.left.equalToSuperview().inset(inset)
        }
        layoutIfNeeded()
    }
}
