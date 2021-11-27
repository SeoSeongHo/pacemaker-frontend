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

struct SignupResponse: Codable {
    let token: String
    let user: User
}
