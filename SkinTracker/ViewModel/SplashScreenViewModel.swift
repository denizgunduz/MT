//
//  SplashScreenViewModel.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 26.11.2021.
//

import Foundation
import CoreData
import SwiftUI

extension SplashScreenView {
    class ViewModel: BaseViewModel {
        var isInited: Bool = false
        
        @Published var users: [User] = []
        
        func fetchUsers() -> Int {
            users = repository.fetchUsers()
            return users.count
        }
        
        func initApp(_ completionHandler: @escaping (_ hasUser: Bool) -> Void) {
            if !isInited {
                if SkinTrackerAppManager.shared.redirectUser {
                    isInited = true
                    
                    SkinTrackerAppManager.shared.settings = repository.fetchSettings()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        completionHandler(true)
                    }
                    return
                }
                
                let userCount = fetchUsers()
                
                if userCount == 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        completionHandler(false)
                    }
                }
                else {
                    if let user = users.first(where: { user in
                        user.lastSelection
                    }) {
                        SkinTrackerAppManager.shared.selectedUser = user
                    }
                    else {
                        SkinTrackerAppManager.shared.selectedUser = users[0]
                    }
                    
                    SkinTrackerAppManager.shared.settings = repository.fetchSettings()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        completionHandler(true)
                    }
                }
                
                isInited = true
            }
        }
    }
}
