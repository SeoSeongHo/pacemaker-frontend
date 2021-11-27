//
//  SessionManager.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/11/27.
//

import Foundation

protocol SessionManager: AnyObject {
    var user: User? { get set }
    var token: String? { get set }
}

final class DefaultSessionManager: SessionManager {
    static let shared = DefaultSessionManager()
    var user: User?
    var token: String?
}
