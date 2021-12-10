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
}

final class DefaultHistoryUseCase: HistoryUseCase {
    private let requestManager = DefaultRequestManager.shared
    func fetchHistries() -> Single<[History]> {
        requestManager.get("/api/v1/users/userHistory", responseType: [History].self)
    }

    func getHistory(userMatchId: Int64) -> Single<History> {
        requestManager.get("/api/v1/users/userHistory/\(userMatchId)", responseType: History.self)
    }
}
