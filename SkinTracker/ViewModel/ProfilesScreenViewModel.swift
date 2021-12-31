//
//  ProfilesScreenViewModel.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 26.11.2021.
//

import Foundation
import CoreData
import SwiftUI

extension ProfilesScreenView {
    class ViewModel: BaseViewModel {
        
        @Published var users: [User] = []
        @Published var userName: String = ""
        @Published var selectedUser: User? = nil
        
        override init() {
            super.init()
            self.users = repository.fetchUsers()
        }
        
        func saveUser() {
            if userName != "" {
                _ = repository.saveUser(userName, true)
                users = repository.fetchUsers()
            }
            else {
                alertMessage = "You should enter user name"
                alertShowing = true
            }
        }
        
        func updateUser(_ user: User) {
            repository.updateUserLastSelection(user)
        }
        
        func updateUsers() {
            repository.save()
        }
        
        func delete(_ user: User) {
            repository.deleteUser(user)
            self.users = repository.fetchUsers()
        }
    }
}
