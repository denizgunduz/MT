//
//  ReminderSettingsScreenViewModel.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 26.11.2021.
//

import Foundation
import CoreData
import SwiftUI

extension ReminderSettingsScreenView {
    class ViewModel: BaseViewModel {
        @Published var selection: Int = 2
        
        private var settings: [Settings] = []
        
        override init() {
            super.init()
            if let setting = repository.fetchSettings() {
                settings.append(setting)
                SkinTrackerAppManager.shared.settings = setting
            }
            
        }
        
        func checkSettings() {
            if !settings.isEmpty {
                selection = Int(settings.first?.notificationPeriod ?? 2) - 1
            }
        }
        
        func saveReminderSelection() {
            SkinTrackerAppManager.shared.settings = repository.saveSettings(selection + 1)
            
            ReminderManager.shared.cancelAll()
            
            let points = repository.fetchBodyPoints()
            points.forEach { point in
                ReminderManager.shared.schedule(point)
            }
        }
    }
}
