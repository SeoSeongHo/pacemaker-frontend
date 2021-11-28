//
//  HistoryCell.swift
//  pacemaker-frontend
//
//  Created by 이지원 on 2021/11/27.
//

import ReactorKit
import RxSwift
import RxDataSources

final class HistoryCell: UITableViewCell {
    static let reuseIdentifier = "HistoryCell"
    
    private let titleLabel = UILabel()
    private let leftArrow = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .black
    }
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(leftArrow)
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(69)
        }
        
        leftArrow.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
    }
    
    func setValue(history: MockHistory) {
        var formatter_time = DateFormatter()
        formatter_time.dateFormat = "HH:mm"
        var current_time_string = formatter_time.string(from: history.time)
        
        titleLabel.numberOfLines = 3
        titleLabel.text = "Distance: " + String(format: "%.1f", history.distances) + "m" + "\nTime: " + current_time_string + "\nRank: " + String(format: "%i", history.rank)
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
    }
}

struct MockHistory {
    var time: Date
    var distances: [Double]
    var rank: Int
}
