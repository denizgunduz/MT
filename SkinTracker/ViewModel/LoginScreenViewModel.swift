//
//  LoginScreenViewModel.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 26.11.2021.
//

import Foundation
import CoreData
import SwiftUI

extension LoginScreenView {
    class ViewModel: BaseViewModel {
        @Published var userName: String = ""
        
        func saveUser(_ completionHandler: () -> Void) {
            if userName != "" {
                SkinTrackerAppManager.shared.selectedUser = repository.saveUser(userName)
                
                let settings = repository.fetchSettings()
                if settings == nil {
                    let setting = repository.saveSettings(NotificationPeriods.every3Months.rawValue)
                    SkinTrackerAppManager.shared.settings = setting
                }
                else {
                    SkinTrackerAppManager.shared.settings = settings
                }
                
                completionHandler()
            }
            else {
                alertMessage = "You should enter user name"
                alertShowing = true
            }
        }
    }
}
