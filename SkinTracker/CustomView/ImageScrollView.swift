//
//  ImageScrollView.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 27.11.2021.
//
/// https://github.com/huynguyencong/ImageScrollView

import UIKit
import SwiftUI

open class ImageScrollViewModel: ObservableObject {
    @Published var contentOffsetX: CGFloat = 0.0
    @Published var contentOffsetY: CGFloat = 0.0
    @Published var zoomScale: CGFloat = 0.0
    
    var photo: BodyPhoto = BodyPhoto()
}

struct ImageScrollViewRepresentable: UIViewRepresentable {
    
    @ObservedObject var viewModel: ImageScrollViewModel
    
    func makeUIView(context: Context) -> some UIView {
        let imageScroll = ImageScrollView()
        imageScroll.backgroundColor = .clear
        
        imageScroll.setup()
        imageScroll.clipsToBounds = true
        imageScroll.imageContentMode = .aspectFill
        imageScroll.initialOffset = .center
        imageScroll.viewModel = viewModel
        
        imageScroll.display(image: UIImage(data: viewModel.photo.data!)!)
        
        return imageScroll
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        let imgScrollView = uiView as? ImageScrollView
        imgScrollView?.zoomScale = viewModel.zoomScale
        imgScrollView?.contentOffset = CGPoint(x: viewModel.contentOffsetX,
                                               y: viewModel.contentOffsetY)
    }
}

open class ImageScrollView: UIScrollView {
    
    @objc public enum ScaleMode: Int {
        case aspectFill
        case aspectFit
        case widthFill
        case heightFill
    }
    
    @objc public enum Offset: Int {
        case begining
        case center
    }
    
    static let kZoomInFactorFromMinWhenDoubleTap: CGFloat = 2
    
    @objc open var imageContentMode: ScaleMode = .widthFill
    @objc open var initialOffset: Offset = .begining
    
    @objc public private(set) var zoomView: UIImageView? = nil

    @ObservedObject var viewModel: ImageScrollViewModel = ImageScrollViewModel()

    var imageSize: CGSize = CGSize.zero
    private var pointToCenterAfterResize: CGPoint = CGPoint.zero
    private var scaleToRestoreAfterResize: CGFloat = 1.0
    open var maxScaleFromMinScale: CGFloat = 5.0

    override open var frame: CGRect {
        willSet {
            if frame.equalTo(newValue) == false && newValue.equalTo(CGRect.zero) == false && imageSize.equalTo(CGSize.zero) == false {
                prepareToResize()
            }
        }
        
        didSet {
            if frame.equalTo(oldValue) == false && frame.equalTo(CGRect.zero) == false && imageSize.equalTo(CGSize.zero) == false {
                recoverFromResizing()
            }
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initialize() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = false
        decelerationRate = UIScrollView.DecelerationRate.fast
        delegate = self
    }
    
    @objc public func adjustFrameToCenter() {
        
        guard let unwrappedZoomView = zoomView else {
            return
        }
        
        var frameToCenter = unwrappedZoomView.frame
        
        // center horizontally
        if frameToCenter.size.width < bounds.width {
            frameToCenter.origin.x = (bounds.width - frameToCenter.size.width) / 2
        }
        else {
            frameToCenter.origin.x = 0
        }
        
        // center vertically
        if frameToCenter.size.height < bounds.height {
            frameToCenter.origin.y = (bounds.height - frameToCenter.size.height) / 2
        }
        else {
            frameToCenter.origin.y = 0
        }
        
        unwrappedZoomView.frame = frameToCenter
    }
    
    private func prepareToResize() {
        let boundsCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        pointToCenterAfterResize = convert(boundsCenter, to: zoomView)
        
        scaleToRestoreAfterResize = zoomScale
        
        // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
        // allowable scale when the scale is restored.
        if scaleToRestoreAfterResize <= minimumZoomScale + CGFloat(Float.ulpOfOne) {
            scaleToRestoreAfterResize = 0
        }
    }
    
    private func recoverFromResizing() {
        setMaxMinZoomScalesForCurrentBounds()
        
        // restore zoom scale, first making sure it is within the allowable range.
        let maxZoomScale = max(minimumZoomScale, scaleToRestoreAfterResize)
        zoomScale = min(maximumZoomScale, maxZoomScale)
        
        // restore center point, first making sure it is within the allowable range.
        
        // convert our desired center point back to our own coordinate space
        let boundsCenter = convert(pointToCenterAfterResize, to: zoomView)
        
        // calculate the content offset that would yield that center point
        var offset = CGPoint(x: boundsCenter.x - bounds.size.width/2.0, y: boundsCenter.y - bounds.size.height/2.0)
        
        // restore offset, adjusted to be within the allowable range
        let maxOffset = maximumContentOffset()
        let minOffset = minimumContentOffset()
        
        var realMaxOffset = min(maxOffset.x, offset.x)
        offset.x = max(minOffset.x, realMaxOffset)
        
        realMaxOffset = min(maxOffset.y, offset.y)
        offset.y = max(minOffset.y, realMaxOffset)
        
        contentOffset = offset
    }
    
    private func maximumContentOffset() -> CGPoint {
        return CGPoint(x: contentSize.width - bounds.width,y:contentSize.height - bounds.height)
    }
    
    private func minimumContentOffset() -> CGPoint {
        return CGPoint.zero
    }
    
    // MARK: - Set up
    
    open func setup() {
        var topSupperView = superview
        
        while topSupperView?.superview != nil {
            topSupperView = topSupperView?.superview
        }
        
        // Make sure views have already layout with precise frame
        topSupperView?.layoutIfNeeded()
        
        DispatchQueue.main.async {
            self.refresh()
        }
    }

    // MARK: - Display image
    
    @objc open func display(image: UIImage, zoomScale: CGFloat, contentOffset: CGPoint) {
        self.display(image: image)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            if self.viewModel.zoomScale > 0 {
                self.zoomScale = zoomScale
                self.contentOffset = contentOffset
            }
        })
    }
    
    @objc open func display(image: UIImage) {

        if let zoomView = zoomView {
            zoomView.removeFromSuperview()
        }
        
        zoomView = UIImageView(image: image)
        zoomView!.isUserInteractionEnabled = true
        addSubview(zoomView!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ImageScrollView.doubleTapGestureRecognizer(_:)))
        tapGesture.numberOfTapsRequired = 2
        zoomView!.addGestureRecognizer(tapGesture)
        
        configureImageForSize(image.size)
        
        if self.viewModel.zoomScale > 0 {
            self.zoomScale = self.viewModel.zoomScale
            self.contentOffset = CGPoint(x: self.viewModel.contentOffsetX,
                                         y: self.viewModel.contentOffsetY)
        }
    }
    
    private func configureImageForSize(_ size: CGSize) {
        imageSize = size
        contentSize = imageSize
        setMaxMinZoomScalesForCurrentBounds()
        zoomScale = minimumZoomScale
        
        switch initialOffset {
        case .begining:
            contentOffset =  CGPoint.zero
        case .center:
            let xOffset = contentSize.width < bounds.width ? 0 : (contentSize.width - bounds.width)/2
            let yOffset = contentSize.height < bounds.height ? 0 : (contentSize.height - bounds.height)/2

            switch imageContentMode {
            case .aspectFit:
                contentOffset =  CGPoint.zero
            case .aspectFill:
                contentOffset = CGPoint(x: xOffset, y: yOffset)
            case .heightFill:
                contentOffset = CGPoint(x: xOffset, y: 0)
            case .widthFill:
                contentOffset = CGPoint(x: 0, y: yOffset)
            }
        }
    }
    
    private func setMaxMinZoomScalesForCurrentBounds() {
        // calculate min/max zoomscale
        let xScale = bounds.width / imageSize.width    // the scale needed to perfectly fit the image width-wise
        let yScale = bounds.height / imageSize.height   // the scale needed to perfectly fit the image height-wise
    
        var minScale: CGFloat = 1
        
        switch imageContentMode {
        case .aspectFill:
            minScale = max(xScale, yScale)
        case .aspectFit:
            minScale = min(xScale, yScale)
        case .widthFill:
            minScale = xScale
        case .heightFill:
            minScale = yScale
        }
        
        
        let maxScale = maxScaleFromMinScale*minScale
        
        // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
        if minScale > maxScale {
            minScale = maxScale
        }
        
        maximumZoomScale = maxScale
        minimumZoomScale = minScale * 0.999 // the multiply factor to prevent user cannot scroll page while they use this control in UIPageViewController
    }
    
    // MARK: - Gesture
    
    @objc func doubleTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        // zoom out if it bigger than the scale factor after double-tap scaling. Else, zoom in
        if zoomScale >= minimumZoomScale * ImageScrollView.kZoomInFactorFromMinWhenDoubleTap - 0.01 {
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            let center = gestureRecognizer.location(in: gestureRecognizer.view)
            let zoomRect = zoomRectForScale(ImageScrollView.kZoomInFactorFromMinWhenDoubleTap * minimumZoomScale, center: center)
            zoom(to: zoomRect, animated: true)
        }
    }
    
    private func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        
        // the zoom rect is in the content view's coordinates.
        // at a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
        // as the zoom scale decreases, so more content is visible, the size of the rect grows.
        zoomRect.size.height = frame.size.height / scale
        zoomRect.size.width  = frame.size.width  / scale
        
        // choose an origin so as to get the right center.
        zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0)
        zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }
    
    open func refresh() {
        if let image = zoomView?.image {
            display(image: image)
        }
    }
    
    // MARK: - Actions
}

extension ImageScrollView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        viewModel.contentOffsetX = targetContentOffset.pointee.x
        viewModel.contentOffsetY = targetContentOffset.pointee.y
        viewModel.photo.contentOffsetX = targetContentOffset.pointee.x
        viewModel.photo.contentOffsetY = targetContentOffset.pointee.y
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        viewModel.contentOffsetX = contentOffset.x
        viewModel.contentOffsetY = contentOffset.y
        viewModel.zoomScale = zoomScale
        viewModel.photo.contentOffsetX = contentOffset.x
        viewModel.photo.contentOffsetY = contentOffset.y
        viewModel.photo.zoomScale = zoomScale
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustFrameToCenter()
    }
    
}
