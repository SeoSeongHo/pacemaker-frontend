//
//  HistoryUseCase.swift
//  pacemaker-frontend
//
//  Created by 이지원 on 2021/11/27.
//

import Foundation
import RxSwift

protocol HistoryUseCase {
    func fetchHistries() -> Single<[MockHistory]>
}

final class DefaultHistoryUseCase: HistoryUseCase {
    func fetchHistries() -> Single<[MockHistory]> {
        .just([
            MockHistory(time: Date(), distances: [1], rank: 1),
            MockHistory(time: Date(), distances: [1], rank: 2),
            MockHistory(time: Date(), distances: [1], rank: 3),
            MockHistory(time: Date(), distances: [1], rank: 1),
            MockHistory(time: Date(), distances: [1], rank: 2),
            MockHistory(time: Date(), distances: [1], rank: 3),
            MockHistory(time: Date(), distances: [1], rank: 1),
            MockHistory(time: Date(), distances: [1], rank: 2),
            MockHistory(time: Date(), distances: [1], rank: 3),
            MockHistory(time: Date(), distances: [1], rank: 1),
            MockHistory(time: Date(), distances: [1], rank: 2),
            MockHistory(time: Date(), distances: [1], rank: 3),
            MockHistory(time: Date(), distances: [1], rank: 1),
            MockHistory(time: Date(), distances: [1], rank: 2),
            MockHistory(time: Date(), distances: [1], rank: 3),
            MockHistory(time: Date(), distances: [1], rank: 1),
            MockHistory(time: Date(), distances: [1], rank: 2),
            MockHistory(time: Date(), distances: [1], rank: 3)
        ])
    }
}
