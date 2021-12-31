//
//  SkinTrackerApp.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 24.11.2021.
//

import SwiftUI
import CoreData

class SkinTrackerAppManager {
    static let shared = SkinTrackerAppManager()
    var selectedUser: User!
    var settings: Settings!
    var redirectUser: Bool = false
}

@main
struct SkinTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SplashScreenView()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .onAppear {
                self.chekNotificationSettings()
            }
        }
    }
    
    func chekNotificationSettings() {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    
                    if error != nil {
                        // Handle the error here.
                    }
                    
                    // Provisional authorization granted.
                    // Result can ignore, it is for cloudkit sync feature.
                }
            }
        }
    }
}
