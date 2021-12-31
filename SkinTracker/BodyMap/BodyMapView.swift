//
//  ImageScrollView.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 27.11.2021.
//

import UIKit

protocol BodyMapViewTraceDelegate {
    func onSelectedTouchPoint(touchPoint: CGPoint, image: UIImage?)
}

protocol BodyMapViewDelegate {
    func deleteNewPoint()
    func reloadPoints(_ points: [BodyPoint])
}

/// This is an extension on UIView to help take screenshots of any views
extension UIView {
    func takeScreenshot(_ frame: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, UIScreen.main.scale)
        drawHierarchy(in: CGRect(x: -frame.origin.x, y: -frame.origin.y, width: bounds.width, height: bounds.height), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

@IBDesignable
class BodyMapView: UIView, BodyMapViewDelegate {
    
    public var delegate: BodyMapViewTraceDelegate?
    
    private var bodyBezierPath: UIBezierPath? = nil
    private var selectedTouchPoint: CGPoint? = nil
    private var newBenPointView: UIView? = nil
    private var viewModel: HomeScreenView.ViewModel? = nil
    
    var isInZoom = false
    var defaultCenterX: CGFloat?
    var defaultCenterY: CGFloat?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        defaultCenterX = self.center.x
        defaultCenterY = self.center.y
    }
    
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        defaultCenterX = self.center.x
        defaultCenterY = self.center.y
    }
    
    convenience init(frame: CGRect, viewModel: HomeScreenView.ViewModel) {
        self.init(frame: frame)
        self.viewModel = viewModel
        self.viewModel?.delegate = self
    }
    
    override func draw(_ rect: CGRect) {
        bodyBezierPath = StyleKitName.drawCanvas2(frame: rect, resizing: .aspectFit)
    }
    
    public func setCurrentBodyPoints(bodyPoints: [BodyPoint]?) {
        let views = subviews.filter { view in
            view.tag == 10
        }
        views.forEach { v in
            v.removeFromSuperview()
        }
        
        guard let bodyPoints = bodyPoints, bodyPoints.count > 0 else { return }
        
        for bodyPoint in bodyPoints {
            let testFrame = CGRect(x: bodyPoint.x, y: bodyPoint.y, width: 10, height: 10)
            let benView : UIView = UIView(frame: testFrame)
            benView.backgroundColor = UIColor.red
            benView.alpha = 0.7
            benView.tag = 10
            benView.layer.cornerRadius = 5
            self.addSubview(benView)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchPoint = touches.first?.location(in: self),
           let bodyBezierPath = bodyBezierPath {
            
            let wX = 960 / frame.width
            let hY = 2193 / frame.height
            
            let newTouchPoint = CGPoint(x: touchPoint.x * wX, y: touchPoint.y * hY)
            
            if bodyBezierPath.contains(newTouchPoint) { // we detect touch point in body or not here
                if selectedTouchPoint != nil, let viewWithTag = self.viewWithTag(100) {
                    viewWithTag.removeFromSuperview()
                    self.selectedTouchPoint = nil
                }
                
                let testFrame = CGRect(x: touchPoint.x, y: touchPoint.y, width: 20, height: 20)
                
                let benView : UIView = UIView(frame: testFrame)
                benView.backgroundColor = UIColor.red
                benView.alpha = 1
                benView.tag = 100
                benView.layer.cornerRadius = 10
                self.addSubview(benView)
                
                self.newBenPointView = benView
                self.selectedTouchPoint = touchPoint
                
                let image = self.takeScreenshot(CGRect.init(x: CGFloat(touchPoint.x - 110), y: CGFloat(touchPoint.y - 110), width: 220, height: 220))
                
                delegate?.onSelectedTouchPoint(touchPoint: touchPoint, image: image)
                
                print("in")
                
            } else {
                print("out")
            }
        }
    }
    
    func deleteNewPoint() {
        newBenPointView?.removeFromSuperview()
    }
    
    func reloadPoints(_ points: [BodyPoint]) {
        setCurrentBodyPoints(bodyPoints: points)
    }
}
