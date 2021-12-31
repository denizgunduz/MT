//
//  BodyMapViewRepresantable.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 26.11.2021.
//

import Foundation
import SwiftUI

struct BodyMapViewRepresantable: UIViewRepresentable {
    
    @State var touchPoint: CGPoint? = nil
    @Binding var savedPoints: [BodyPoint]
    
    var viewModel: HomeScreenView.ViewModel
    var onSelectedPoint: (_ point: CGPoint, _ image: UIImage?) -> Void
    
    class Coordinator: BodyMapViewTraceDelegate {
        
        var parent: BodyMapViewRepresantable

        init(_ parent: BodyMapViewRepresantable) {
            self.parent = parent
        }

        func onSelectedTouchPoint(touchPoint: CGPoint, image: UIImage?) {
            self.parent.touchPoint = touchPoint
            self.parent.onSelectedPoint(touchPoint, image)
        }
        
        func logoTraceComplete() {
            
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> some UIView {
        let bodyMap = BodyMapView(frame: .zero, viewModel: viewModel)
        bodyMap.backgroundColor = .clear
        bodyMap.delegate = context.coordinator
        return bodyMap
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        (uiView as? BodyMapView)?.setCurrentBodyPoints(bodyPoints: self.savedPoints)
    }
}
