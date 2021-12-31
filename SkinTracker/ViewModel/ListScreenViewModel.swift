//
//  ListScreenViewModel.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 27.11.2021.
//

import Foundation
import CoreData

extension ListScreenView {
    class ViewModel: BaseViewModel {
        @Published var points: [BodyPoint] = []
        
        override init() {
            super.init()
            fetchPoints()
        }
        
        func fetchPoints() {
            if let points = SkinTrackerAppManager.shared.selectedUser.bodyPoints?.map({ item in
                item as! BodyPoint
            }) {
                self.points = points.sorted(by: { b1, b2 in
                    b1.addDate! > b2.addDate!
                })
            }
        }
        
        func delete(_ point: BodyPoint) {
            repository.deleteBodyPoint(point)
            
            ReminderManager.shared.cancel(point.objectID.uriRepresentation().absoluteString)
            
            fetchPoints()
        }
        
        func calculateLeftDays(_ point: BodyPoint) -> Int {
            return ReminderManager.shared.calculateLeft(point)
        }
    }
}
