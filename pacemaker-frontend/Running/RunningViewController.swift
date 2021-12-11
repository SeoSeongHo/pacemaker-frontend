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
        if reactor.match.users.count > 0 {
            progressView.progressLabel.textColor = .primary
            progressView.progressView.backgroundColor = .primary
            progressView.id = reactor.match.users[0].id
            progressView.progressLabel.text = reactor.match.users[0].nickname
        }
        if reactor.match.users.count > 1 {
            progressView1.id = reactor.match.users[1].id
            progressView1.progressLabel.text = reactor.match.users[1].nickname
        }
        if reactor.match.users.count > 2 {
            progressView2.id = reactor.match.users[2].id
            progressView2.progressLabel.text = reactor.match.users[2].nickname
        }
        if reactor.match.users.count > 3 {
            progressView3.id = reactor.match.users[3].id
            progressView3.progressLabel.text = reactor.match.users[3].nickname
        }

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
                        reactor.action.onNext(.giveup)
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
            })
            .disposed(by: disposeBag)

        reactor.state.map(\.matchUser)
            .subscribe(onNext: { [weak self] matchUser in
                matchUser.enumerated().forEach { index, user in
                    switch index {
                    case 0:
                        let progress = user.currentDistance / Double(reactor.distance)
                        self?.progressView.setProgress(progress, speed: user.currentSpeed)
                    case 1:
                        let progress = user.currentDistance / Double(reactor.distance)
                        self?.progressView1.setProgress(progress, speed: user.currentSpeed)
                    case 2:
                        let progress = user.currentDistance / Double(reactor.distance)
                        self?.progressView2.setProgress(progress, speed: user.currentSpeed)
                    case 3:
                        let progress = user.currentDistance / Double(reactor.distance)
                        self?.progressView3.setProgress(progress, speed: user.currentSpeed)
                    default:
                        break
                    }
                }
            })
            .disposed(by: disposeBag)

        reactor.donePublisher
            .subscribe(onNext: { [weak self] history in
                guard let self = self else { return }
                let vc = self.presentingViewController
                self.dismiss(animated: true, completion: { [weak vc] in
                    let result = HistoryDetailViewController(history: history)
                    vc?.present(result, animated: true)
                })
            })
            .disposed(by: disposeBag)


        typealias Scanned = (Int, Int)
        let first: Scanned = (0, 0)
        reactor.state.map(\.myPlace)
            .skip(.seconds(5), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .scan(first) { (last, new) in
                return (last.1, new)
            }
            .subscribe(onNext: { (prev, next) in
                if next == 1 {
                    reactor.notification(for: .FIRST_PLACE)
                } else if prev < next {
                    reactor.notification(for: .OVERTAKEN)
                } else if prev > next {
                    reactor.notification(for: .OVERTAKING)
                }
            })
            .disposed(by: disposeBag)

        reactor.state.map(\.finishedUser.count)
            .distinctUntilChanged()
            .subscribe(onNext: { count in
                if count > 0 {
                    reactor.notification(for: .FINISH_OTHER)
                }
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(
            reactor.state.map(\.meanSpeed).distinctUntilChanged(),
            reactor.state.map(\.speed).distinctUntilChanged()
        )
            .subscribe(onNext: { mean, current in
                if current < mean * 0.5 {
                    reactor.notification(for: .SPEED_UP)
                }
                else if current > mean * 1.5 {
                    reactor.notification(for: .SPEED_DOWN)
                }
            })
            .disposed(by: disposeBag)

    }
}

class ProgressView: UIView {
    var id: Int64?

    let progressView = UIView().then {
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

    let speedLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .bold)
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
        addSubview(speedLabel)
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

        speedLabel.snp.makeConstraints { make in
            make.centerX.equalTo(progressIndicatorView)
            make.top.equalTo(progressIndicatorView.snp.bottom).offset(5)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setProgress(_ progress: Double, speed: Double) {
        let progress = min(progress, 1)
        let inset = (bounds.width - 20) * progress

        progressIndicatorView.snp.updateConstraints { make in
            make.left.equalToSuperview().inset(inset)
        }

        speedLabel.text = "\(String(format: "%.2f", max(0, speed)))m/s"

        layoutIfNeeded()
    }
}
