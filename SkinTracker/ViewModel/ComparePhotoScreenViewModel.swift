//
//  ComparePhotoScreenViewModel.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 28.11.2021.
//

import Foundation

extension ComparePhotoScreenView {
    class ViewModel: BaseViewModel {
        @Published var topSelection: Int = 0
        @Published var bottomSelection: Int = 0
        @Published var pictures = [BodyPhoto]()
        
        var models: [ImageScrollViewModel] = []
        
        func preparePhotos(_ bodyPoint: BodyPoint) {
            if let pictures = bodyPoint.photos?.map({ item in
                item as! BodyPhoto
            }) {
                print("pic count: \(pictures.count)")
                if pictures.count != self.pictures.count {
                    
                    bottomSelection = pictures.count > 1 ? pictures.count - 2 : 0
                    topSelection = pictures.count > 0 ? pictures.count - 1 : 0
                    
                    self.pictures = pictures.sorted(by: { p1, p2 in
                        p1.addDate! < p2.addDate!
                    })
                    
                    models.removeAll()
                    self.pictures.forEach { picture in
                        let vModel = ImageScrollViewModel()
                        vModel.photo = picture
                        vModel.zoomScale = picture.zoomScale
                        vModel.contentOffsetX = picture.contentOffsetX
                        vModel.contentOffsetY = picture.contentOffsetY
                        models.append(vModel)
                    }
                }
            }
        }
        
        func saveData() {
            try? PersistenceController.shared.container.viewContext.save()
        }
    }
}
