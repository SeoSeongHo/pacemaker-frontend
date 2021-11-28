//
//  HistoryViewController.swift
//  pacemaker-frontend
//
//  Created by 이지원 on 2021/11/27.
//

import UIKit
import RxCocoa
import RxSwift
import ReactorKit
import Then
import SnapKit

class HistoryViewController: UIViewController, View {
    private let tableView = UITableView().then {
        $0.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.reuseIdentifier)
    }
    
    private let labelNoHistory = UILabel().then {
            $0.text = "No History"
            $0.font = .systemFont(ofSize: 24)
            $0.textAlignment = .center
    }
    
    var disposeBag = DisposeBag()
    
    private func configure() {
        navigationItem.title = "History"
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        
        view.addSubview(labelNoHistory)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview().inset(10)
        }
        
        labelNoHistory.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    init(reactor: HistoryViewReactor) {
        super.init(nibName: nil, bundle: nil)

        defer { self.reactor = reactor }

        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: HistoryViewReactor) {
        reactor.action.onNext(.fetchHistories)
        
        reactor.state.map(\.histories)
            .bind(to: tableView.rx.items(cellIdentifier: HistoryCell.reuseIdentifier, cellType: HistoryCell.self)) { index, item, cell in
                cell.setValue(history: item)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(MockHistory.self)
            .subscribe(onNext: { [weak self] history in
                let viewController = HistoryDetailViewController(history: history)
                self?.navigationController?.pushViewController(viewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}


