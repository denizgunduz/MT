//
//  CameraViewModel.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 27.11.2021.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation
import Camera_SwiftUI

final class CameraViewModel: BaseViewModel {
    private let service = CameraService()
    
    @Published var photo: Photo? = nil
    
    @Published var pickedImage: UIImage? = nil
    
    @Published var showAlertError = false
    
    @Published var isFlashOn = false
    
    @Published var willCapturePhoto = false
    
    @Published var isRetakePhoto = false
    
    @Published var lastBodyPhoto: BodyPhoto? = nil
    
    @Published var isOverlap: Bool = false
    
    var point: CGPoint = CGPoint()
    var sideType: Int = 0
    var previewImage: UIImage? = nil
    var bodyPoint: BodyPoint? = nil
    
    var alertError: AlertError!
    
    var session: AVCaptureSession? = nil
    
    private var subscriptions = Set<AnyCancellable>()
    
    override init() {
        super.init()
        self.session = service.session
        
        service.$photo.sink { [weak self] (photo) in
            guard let pic = photo else { return }
            self?.photo = pic
            print("photo captured")
        }
        .store(in: &self.subscriptions)
        
        service.$shouldShowAlertView.sink { [weak self] (val) in
            self?.alertError = self?.service.alertError
            self?.showAlertError = val
        }
        .store(in: &self.subscriptions)
        
        service.$flashMode.sink { [weak self] (mode) in
            self?.isFlashOn = mode == .on
        }
        .store(in: &self.subscriptions)
        
        service.$willCapturePhoto.sink { [weak self] (val) in
            self?.willCapturePhoto = val
        }
        .store(in: &self.subscriptions)
    }
    
    func configure() {
        service.checkForPermissions()
        service.configure()
    }
    
    func capturePhoto() {
        service.capturePhoto()
    }
    
    func flipCamera() {
        service.changeCamera()
    }
    
    func zoom(with factor: CGFloat) {
        service.set(zoom: factor)
    }
    
    func switchFlash() {
        service.flashMode = service.flashMode == .on ? .off : .on
    }
    
    func savePhoto(_ image: UIImage) {
        var bPoint: BodyPoint = BodyPoint()
        if bodyPoint != nil {
            bPoint = self.bodyPoint!
        }
        else {
            bPoint = repository.saveBodyPoint(point, sideType, previewImage)
        }
        
        bPoint.lastPhotoDate = Date()
        
        _ = repository.saveBodyPhoto(bPoint, image)
        
        print("ObjectId: \(bPoint.objectID.uriRepresentation().absoluteString)")
        ReminderManager.shared.cancel(bPoint.objectID.uriRepresentation().absoluteString)
        ReminderManager.shared.schedule(bPoint)
    }
    
    func getLastPhoto() {
        var photos = bodyPoint?.photos?.map({ photo in
            photo as! BodyPhoto
        })
        
        photos?.sort(by: { p1, p2 in
            p1.addDate! < p2.addDate!
        })
        
        lastBodyPhoto = photos?.last
    }
}

