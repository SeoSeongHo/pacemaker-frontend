//
//  User.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/10/22.
//

import Foundation

struct User: Codable {
    let id: Int64
    let email: String
    let nickname: String
}

struct MatchUser: Codable {
    let id: Int64
    let userMatchId: Int64
    let nickname: String
    let currentDistance: Double
    let currentSpeed: Double
}

struct SignupResponse: Codable {
    let token: String
    let user: User
}

struct MatchResponse: Codable {
    let matchUsers: [MatchUser]
    let alarmCategory: MatchEvent?
}
