//
//  ReminderManager.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 29.11.2021.
//

import Foundation
import UserNotifications

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}

class ReminderManager {
    static let shared = ReminderManager()
    
    func calculateLeft(_ point: BodyPoint) -> Int {
        let period = Int(SkinTrackerAppManager.shared.settings.notificationPeriod)
        let diff = Calendar.current.dateComponents([.day], from: point.lastPhotoDate!, to: Date()).day ?? 0
        
        var leftDays: Int = 0
        
        switch period {
        case NotificationPeriods.every2Mins.rawValue: do { // this is only for testing
            let diffMin = Calendar.current.dateComponents([.minute], from: point.lastPhotoDate!, to: Date()).minute ?? 0
            if diffMin < 10 {
                leftDays = 10 - diffMin
            }
            break;
        }
        case NotificationPeriods.everyMonths.rawValue: do {
            if diff < 30 {
                leftDays = 30 - diff
            }
            break;
        }
        case NotificationPeriods.every2Months.rawValue: do {
            if diff < 60 {
                leftDays = 60 - diff
            }
            break;
        }
        case NotificationPeriods.every3Months.rawValue: do {
            if diff < 90 {
                leftDays = 90 - diff
            }
            break;
        }
        case NotificationPeriods.every6Months.rawValue: do {
            if diff < 180 {
                leftDays = 180 - diff
            }
            break;
        }
        case NotificationPeriods.every12Months.rawValue: do {
            if diff < 365 {
                leftDays = 365 - diff
            }
            break;
        }
        default: break;
        }
        
        return leftDays > 0 ? leftDays : 0
    }
    
    func schedule(_ point: BodyPoint) {
        let content = UNMutableNotificationContent()
        content.title = "\(point.user?.name ?? "Your")'s body point reminder"
        content.body = "You should take a new photo of your mole."
        content.sound = UNNotificationSound.default
        
        content.userInfo["userObjectId"] = point.user?.id?.uuidString
        
        let period = Int(SkinTrackerAppManager.shared.settings.notificationPeriod)
        let diff = Calendar.current.dateComponents([.day], from: point.lastPhotoDate!, to: Date()).day ?? 0
        
        // Configure the recurring date.
        var dateComponents = DateComponents()
        
        switch period {
        case NotificationPeriods.every2Mins.rawValue: do { // this is only for testing
            let diffMin = Calendar.current.dateComponents([.minute], from: point.lastPhotoDate!, to: Date()).minute ?? 0
            if diffMin < 10 {
                let leftDays = 2 - diffMin
                dateComponents = Calendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year],
                                                                 from: Calendar.current.date(byAdding: .minute, value: leftDays, to: Date())!)
            }
            break;
        }
        case NotificationPeriods.everyMonths.rawValue: do {
            if diff < 30 {
                let leftDays = 30 - diff
                dateComponents = Calendar.current.dateComponents([.hour, .day, .month, .year],
                                                                 from: Calendar.current.date(byAdding: .day, value: leftDays, to: Date())!)
            }
            break;
        }
        case NotificationPeriods.every2Months.rawValue: do {
            if diff < 60 {
                let leftDays = 60 - diff
                dateComponents = Calendar.current.dateComponents([.hour, .day, .month, .year],
                                                                 from: Calendar.current.date(byAdding: .day, value: leftDays, to: Date())!)
            }
            break;
        }
        case NotificationPeriods.every3Months.rawValue: do {
            if diff < 90 {
                let leftDays = 90 - diff
                dateComponents = Calendar.current.dateComponents([.hour, .day, .month, .year],
                                                                 from: Calendar.current.date(byAdding: .day, value: leftDays, to: Date())!)
            }
            break;
        }
        case NotificationPeriods.every6Months.rawValue: do {
            if diff < 180 {
                let leftDays = 180 - diff
                dateComponents = Calendar.current.dateComponents([.hour, .day, .month, .year],
                                                                 from: Calendar.current.date(byAdding: .day, value: leftDays, to: Date())!)
            }
            break;
        }
        case NotificationPeriods.every12Months.rawValue: do {
            if diff < 365 {
                let leftDays = 365 - diff
                dateComponents = Calendar.current.dateComponents([.hour, .day, .month, .year],
                                                                 from: Calendar.current.date(byAdding: .day, value: leftDays, to: Date())!)
            }
            break;
        }
        default: break;
        }
        
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
                 dateMatching: dateComponents, repeats: false)
        
        // Create the request
        let uuidString = point.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
           if error != nil {
              // Handle any errors.
           }
        }
    }
    
    func cancel(_ id: String) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
    }
    
    func cancelAll() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
