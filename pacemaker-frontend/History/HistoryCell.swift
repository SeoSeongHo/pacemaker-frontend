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

    private let rankLabel = UILabel().then {
        $0.textColor = .primary
        $0.font = .systemFont(ofSize: 15)
    }
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15)
    }
    private let leftArrow = UIImageView().then {
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .primary
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
        contentView.addSubview(rankLabel)
        contentView.addSubview(leftArrow)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(24)
            make.left.equalToSuperview().inset(24)
        }

        rankLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(leftArrow.snp.left).offset(-10)
        }
        
        leftArrow.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
    }
    
    func setValue(history: History) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY.MM.dd HH:mm"
        let timeString = formatter.string(from: history.matchStartDatetime)

        titleLabel.text = timeString
        rankLabel.text = "\(history.rank) / \(history.totalMembers)"
    }
}

struct MockHistory {
    var time: Date
    var distances: [Double]
    var rank: Int
}

struct History: Codable {
    let id: Int64
    let totalDistance: Int
    let matchStartDatetime: Date
    let matchEndDatetime: Date
    let totalTime: Int
    let rank: Int
    let totalMembers: Int
    let maximumSpeed: Double
    let graph: [Double]
}
