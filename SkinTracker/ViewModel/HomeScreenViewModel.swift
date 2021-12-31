//
//  HomeScreenViewModel.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 26.11.2021.
//

import Foundation
import UIKit
import CoreData

extension HomeScreenView {
    class ViewModel: BaseViewModel {
        @Published var isFrontSide: Bool = true
        @Published var touchPoint: CGPoint? = nil
        @Published var previewImage: UIImage? = nil
        @Published var bodyPoints: [BodyPoint] = []
        
        var delegate: BodyMapViewDelegate? = nil
        
        func fetchPoints(_ side: Int = 1) {
            if let points = SkinTrackerAppManager.shared.selectedUser.bodyPoints?.map({ item in
                item as! BodyPoint
            }) {
                self.bodyPoints = points.filter({ point in
                    point.sideType == side
                })
                
                self.delegate?.reloadPoints(self.bodyPoints)
            }
        }
    }
}
