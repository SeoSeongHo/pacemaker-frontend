//
//  HistoryDetailViewController.swift
//  pacemaker-frontend
//
//  Created by 이지원 on 2021/11/27.
//

import UIKit
import ReactorKit
import RxSwift
import SwiftUI

class HistoryDetailViewController: UIViewController {
    private let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: nil, action: nil).then {
        $0.tintColor = .black
    }
    
    private let resultLabel = UILabel()
    
    var disposeBag = DisposeBag()
    
    private func configure() {
        navigationItem.leftBarButtonItem = backButton
        navigationItem.title = "Result"
        view.backgroundColor = .white
        
        view.addSubview(resultLabel)
        
        resultLabel.snp.makeConstraints {make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
    }
    
    init(history : MockHistory) {
        super.init(nibName: nil, bundle: nil)
        
        configure()
        
        setValue(history: history)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setValue(history: MockHistory) {
        var formatter_time = DateFormatter()
        formatter_time.dateFormat = "HH:mm"
        var current_time_string = formatter_time.string(from: history.time)
        
        resultLabel.text = "Distance: " + String(format: "%.1f", history.distances) + "m" + "\nTime: " + current_time_string + "\nRank: " + String(format: "%i", history.rank)
        resultLabel.numberOfLines = 3
        resultLabel.font = .systemFont(ofSize: 20, weight: .bold)
    }
}
