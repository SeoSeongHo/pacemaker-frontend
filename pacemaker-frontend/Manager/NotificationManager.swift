//
//  NotificationManager.swift
//  pacemaker-frontend
//
//  Created by 이동현 on 2021/11/27.
//

import Foundation
import UIKit

protocol NotificationManager {
    func start()
    func finish()
    func left100()
    func left50()
    func overtaken()
    func overtaking()
    func finishOther()
    func done()
    func firstPlace()
}

final class DefaultNotificationManager: NotificationManager {
    func start() {
        makeNotification(
            title: "레이스가 시작되었어요.",
            sound: "start.mp3"
        )
    }

    func finish() {
        makeNotification(
            title: "레이스를 완료했어요.",
            body: "고생했어요!",
            sound: "finish.mp3"
        )
    }

    func left100() {
        makeNotification(
            title: "100m 남았어요",
            sound: "100.mp3"
        )
    }

    func left50() {
        makeNotification(
            title: "50m 남았어요",
            sound: "50.mp3"
        )
    }

    func overtaken() {
        makeNotification(
            title: "추월당했어요",
            sound: "overtaken.mp3"
        )
    }

    func overtaking() {
        makeNotification(
            title: "추월했어요",
            sound: "overtaking.mp3"
        )
    }


    func finishOther() {
        makeNotification(
            title: "누군가가 레이스를 완료했어요",
            sound: "finish_other.mp3"
        )
    }

    func done() {
        makeNotification(
            title: "레이스가 모두 종료되었어요",
            sound: "done.mp3"
        )
    }

    func firstPlace() {
        makeNotification(
            title: "1등이에요!",
            sound: "first.mp3"
        )
    }


    private func makeNotification(
        title: String,
        body: String? = nil,
        sound: String?
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body ?? title
        if let sound = sound {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: sound))
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
        let request = UNNotificationRequest(identifier: "timerdone", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error:Error?) in
            if error != nil {
                print(error?.localizedDescription ?? "some unknown error")
            }
            print("Notification Register Success")
        }
    }
}
