//
//  BaseViewModel.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 26.11.2021.
//

import Foundation
import CoreData

class BaseViewModel: ObservableObject {
    @Published var alertShowing: Bool = false
    @Published var alertMessage: String = ""
    @Published var navigation: Navigation = Navigation()
    
    let repository = PersistenceController.shared
}
