//
//  CameraScreenView.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 27.11.2021.
//

import SwiftUI
import Camera_SwiftUI

struct ScanOverlayView: View {
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let cutoutWidth: CGFloat = min(geometry.size.width, geometry.size.height) / 1.5

            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                
                RoundedRectangle(cornerRadius: cutoutWidth / 2)
                    .fill(Color.black)
                    .frame(width: cutoutWidth, height: cutoutWidth, alignment: .center)
                    .blendMode(.destinationOut)
                
                if viewModel.isOverlap {
                    if let imgData = self.viewModel.lastBodyPhoto?.data {
                        Image(uiImage: UIImage.init(data: imgData)!)
                            .resizable()
                            .scaledToFit()
                            .opacity(0.55)
                    }
                }
                
                Image("camera-pointer")
                    .resizable()
                    .frame(width: cutoutWidth, height: cutoutWidth, alignment: .center)
                    .opacity(viewModel.isOverlap ? 0.4 : 0.2)
                
                if !viewModel.isOverlap {
                    VStack {
                        Text("Hold the camera at a 90 degree right angle to the point you want to focus on and take the picture")
                            .foregroundColor(.white)
                            .frame(alignment: .top)
                            .padding(40)
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                }
            }.compositingGroup()
        }
    }
}

struct CameraScreenView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel = CameraViewModel()
    
    @State var currentZoomFactor: CGFloat = 1.0
    
    var completionHandler: (_ photo: Photo) -> Void
    var point: CGPoint = CGPoint()
    var sideType: Int = 0
    var previewImage: UIImage? = nil
    
    var bodyPoint: BodyPoint? = nil
    
    var captureButton: some View {
        Button(action: {
            viewModel.capturePhoto()
        }, label: {
            Circle()
                .foregroundColor(.white)
                .frame(width: 80, height: 80, alignment: .center)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 2)
                        .frame(width: 65, height: 65, alignment: .center)
                )
        })
    }
    
    var flipCameraButton: some View {
        Button(action: {
            viewModel.flipCamera()
        }, label: {
            Circle()
                .foregroundColor(Color.gray.opacity(0.2))
                .frame(width: 45, height: 45, alignment: .center)
                .overlay(
                    Image(systemName: "camera.rotate.fill")
                        .foregroundColor(.white))
        })
    }
    
    var body: some View {
        GeometryReader { reader in
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20, weight: .medium, design: .default))
                        })
                        .accentColor(.white)
                        
                        Spacer()
                        Button(action: {
                            viewModel.switchFlash()
                        }, label: {
                            Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                                .font(.system(size: 20, weight: .medium, design: .default))
                        })
                        .accentColor(viewModel.isFlashOn ? .yellow : .white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    ZStack {
                        CameraPreview(session: viewModel.session!)
                            .gesture(
                                DragGesture().onChanged({ (val) in
                                    //  Only accept vertical drag
                                    if abs(val.translation.height) > abs(val.translation.width) {
                                        //  Get the percentage of vertical screen space covered by drag
                                        let percentage: CGFloat = -(val.translation.height / reader.size.height)
                                        //  Calculate new zoom factor
                                        let calc = currentZoomFactor + percentage
                                        //  Limit zoom factor to a maximum of 5x and a minimum of 1x
                                        let zoomFactor: CGFloat = min(max(calc, 1), 5)
                                        //  Store the newly calculated zoom factor
                                        currentZoomFactor = zoomFactor
                                        //  Sets the zoom factor to the capture device session
                                        viewModel.zoom(with: zoomFactor)
                                    }
                                })
                            )
                            .onAppear {
                                viewModel.configure()
                                
                                viewModel.sideType = sideType
                                viewModel.point = point
                                viewModel.previewImage = previewImage
                                viewModel.bodyPoint = bodyPoint
                                
                                viewModel.getLastPhoto()
                            }
                            .alert(isPresented: $viewModel.showAlertError, content: {
                                Alert(title: Text(viewModel.alertError.title), message: Text(viewModel.alertError.message), dismissButton: .default(Text(viewModel.alertError.primaryButtonTitle), action: {
                                    viewModel.alertError.primaryAction?()
                                }))
                            })
                            .overlay(
                                Group {
                                    if viewModel.willCapturePhoto {
                                        Color.black
                                    }
                                    else {
                                    //else if !viewModel.isOverlap {
                                        ScanOverlayView(viewModel: viewModel)
                                    }
                                }
                            )
                            .animation(.easeOut, value: 1)
                    }
                    
                    if self.viewModel.lastBodyPhoto?.data != nil {
                        Toggle(isOn: $viewModel.isOverlap) {
                            Text("Overlap Last Photo")
                                .foregroundColor(.white)
                        }
                        .toggleStyle(SwitchToggleStyle())
                        .padding(.horizontal, 20)
                    }
                             
                    HStack {
                        Group {
                            Button {
                                viewModel.navigation.present(.fullScreenCover) {
                                    ImagePicker(selectedImage: $viewModel.pickedImage)
                                } onDismiss: {
                                    if let image = viewModel.pickedImage {
                                        viewModel.savePhoto(image)
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            } label: {
                                Text("Photo Gallery")
                                    .font(.system(size: 12))
                            }
                        }
                        
                        Spacer()
                        
                        captureButton
                        
                        Spacer()
                        
                        flipCameraButton
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .uses(viewModel.navigation)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.photo) { newValue in
            if newValue != nil {
                viewModel.isRetakePhoto = false
                viewModel.navigation.present(.fullScreenCover) {
                    ImagePreview(viewModel: viewModel)
                } onDismiss: {
                    if !viewModel.isRetakePhoto {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ImagePreview: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CameraViewModel
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button(action: {
                        viewModel.isRetakePhoto = true
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .medium, design: .default))
                    })
                    .accentColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
                
                if viewModel.photo != nil {
                    Image(uiImage: (viewModel.photo?.image)!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width)
                        .animation(.spring(), value: 1)
                        .padding(.top)
                }
                
                Spacer()
                
                HStack(spacing: 24) {
                    Spacer()
                    Button(action: {
                        viewModel.isRetakePhoto = true
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Retake")
                    })
                    .accentColor(.white)
                    
                    Button(action: {
                        viewModel.isRetakePhoto = false
                        if let image = viewModel.photo?.image {
                            viewModel.savePhoto(image)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Save")
                    })
                    .accentColor(.white)
                    Spacer()
                }
            }
        }
    }
}

struct CameraScreenView_Previews: PreviewProvider {
    static var previews: some View {
        CameraScreenView(completionHandler: { p in
            
        }, point: CGPoint.init(), sideType: 0)
    }
}
