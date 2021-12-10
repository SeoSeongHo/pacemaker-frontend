//
//  HistoryUseCase.swift
//  pacemaker-frontend
//
//  Created by 이지원 on 2021/11/27.
//

import Foundation
import RxSwift

protocol HistoryUseCase {
    func fetchHistries() -> Single<[History]>
    func getHistory(userMatchId: Int64) -> Single<History>
}

final class DefaultHistoryUseCase: HistoryUseCase {
    var graph: [Double] {
        [
            2,
            2.8,
            3,
            3.2,
            3.9,
            4,
            3.5,
            3.9,
            4.5,
            4.6,
            4.1,
            3.5,
            4.2,
            4.7,
            4.2,
            3.8,
            3.1,
            2.6,
            2.3,
            2.1,
            1.3,
            0.6
        ]
    }
    private let requestManager = DefaultRequestManager.shared
    func fetchHistries() -> Single<[History]> {
        return requestManager.get("/api/v1/users/userHistory", responseType: HistoryResponse.self)
            .map(\.userHistoryList)

        return .just([
            History(id: 1, totalDistance: 1000, matchStartDatetime: Date(), matchEndDatetime: Date(), totalTime: 1, rank: 1, totalMembers: 3, maximumSpeed: 10, graph: graph),
            History(id: 1, totalDistance: 1000, matchStartDatetime: Date(), matchEndDatetime: Date(), totalTime: 1, rank: 1, totalMembers: 3, maximumSpeed: 10, graph: graph),
            History(id: 1, totalDistance: 1000, matchStartDatetime: Date(), matchEndDatetime: Date(), totalTime: 1, rank: 1, totalMembers: 3, maximumSpeed: 10, graph: graph)
        ])
    }

    func getHistory(userMatchId: Int64) -> Single<History> {
        requestManager.get("/api/v1/matches/history/\(userMatchId)", responseType: History.self)
    }
}


struct HistoryResponse: Codable {
    let userHistoryList: [History]
}
