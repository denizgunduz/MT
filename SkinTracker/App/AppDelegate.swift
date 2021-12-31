//
//  AppDelegate.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 25.11.2021.
//

import Foundation
import UIKit
import CoreData
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        PersistenceController.shared.save()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            
            print("userNotificationCenter, willPresent")
            completionHandler(.badge)
        }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
            
            print("userNotificationCenter, didReceive")
            
            if let id: String = response.notification.request.content.userInfo["userObjectId"] as? String {
                let context = PersistenceController.shared.container.viewContext
                let request: NSFetchRequest<User> = User.fetchRequest()
                
                do {
                    let usersCoreData = try context.fetch(request)
                    if let user = usersCoreData.first(where: { user in
                        user.id?.uuidString == id
                    }) {
                        SkinTrackerAppManager.shared.selectedUser = user
                        SkinTrackerAppManager.shared.redirectUser = true
                    }
                } catch {
                    print("Fetch failed: Error \(error.localizedDescription)")
                }
            }
            else {
                print("userId not provided.")
            }
            
            completionHandler()
        }
}
