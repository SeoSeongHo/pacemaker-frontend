//
//  MatchUseCase.swift
//  pacemaker-frontend
//
//  Created by 이지원 on 2021/11/01.
//

import Foundation
import RxSwift

protocol MatchUseCase {
    func start(distance: Int, memberCount: Int) -> Single<Match>
    func cancel(distance: Int, memberCount: Int) -> Single<Match>
    func sendMatchInfo(userMatchId: Int64, distance: Double, currentSpeed: Double, count: Int) -> Single<MatchResponse>

    var matchPollingInterval: Int { get }
}

final class DefaultMatchUseCase: MatchUseCase {
    static let shared = DefaultMatchUseCase()

    private let requestManager: RequestManager = DefaultRequestManager.shared
    var matchPollingInterval: Int = 1

    func start(distance: Int, memberCount: Int) -> Single<Match> {
//        var users: [User] = []
//        for _ in 0..<memberCount {
//            users.append(User(id: 1, email: "", nickname: ""))
//        }
//
//        return .just(Match(status: Bool.random() && Bool.random(), startDatetime: Date(), users: users))

        return requestManager.post(
            "/api/v1/matches",
            parameters: ["distance": distance, "participants": memberCount],
            responseType: Match.self
        )
    }

    func cancel(distance: Int, memberCount: Int) -> Single<Match> {
        return requestManager.post(
            "/api/v1/matches/cancel",
            parameters: ["distance": distance, "participants": memberCount],
            responseType: Match.self
        )
    }

    func sendMatchInfo(userMatchId: Int64, distance: Double, currentSpeed: Double, count: Int) -> Single<MatchResponse> {
        return requestManager.post(
            "/api/v1/matches/poll",
            parameters: [
                "userMatchId": userMatchId,
                "currentDistance": distance,
                "currentSpeed": currentSpeed,
                "count": count
            ],
            responseType: MatchResponse.self
        )
    }
}

struct Match: Codable {
    let status: MatchStatus
    let startDatetime: Date
    let users: [MatchUser]
}

enum MatchStatus: String, Codable {
    case NONE
    case MATCHING
    case MATCHING_COMPLETE
    case DONE
    case ERROR
}

enum MatchEvent: String, CaseIterable, Codable {
    case NONE
    case LEFT_100M
    case LEFT_50M
    case OVERTAKEN
    case OVERTAKING
    case FINISH
    case FINISH_OTHER
    case DONE
    case FIRST_PLACE
}
