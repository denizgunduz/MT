//
//  ComparePhotoScreenView.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 27.11.2021.
//

import SwiftUI

struct ComparePhotoScreenView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = ViewModel()
    var bodyPoint: BodyPoint
    var dateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateFormat = "dd.MM.yyyy HH:mm"
      return formatter
    }()
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 12) {
                    ZStack {
                        if viewModel.models.count > 0 {
                            TabView(selection: $viewModel.topSelection) {
                                ForEach(viewModel.models.indices, id: \.self) { index in
                                    ZStack(alignment: .bottomTrailing) {
                                        ImageScrollViewRepresentable(viewModel: viewModel.models[index])
                                        
                                        VStack {
                                            Text("\(self.dateFormatter.string(from: viewModel.models[index].photo.addDate!))")
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 5)
                                                .foregroundColor(.white)
                                        }
                                        .background(Color.black.opacity(0.4))
                                    }
                                    .tag(index)
                                }
                            }
                            .tabViewStyle(.page)
                        }
                        
                        HStack {
                            Button {
                                if viewModel.topSelection > 0 {
                                    viewModel.topSelection = viewModel.topSelection - 1
                                }
                            } label: {
                                Image(systemName: "chevron.backward")
                                    .font(.system(size: 45, weight: .medium, design: .default))
                            }
                            
                            Spacer()
                            
                            Button {
                                if viewModel.topSelection < viewModel.pictures.count - 1 {
                                    viewModel.topSelection = viewModel.topSelection + 1
                                }
                            } label: {
                                Image(systemName: "chevron.forward")
                                    .font(.system(size: 45, weight: .medium, design: .default))
                            }
                        }
                        .frame(height: geo.size.height/2 - 30, alignment: .center)
                        .padding(.horizontal)
                    }
                    .frame(height: geo.size.height/2 - 30, alignment: .center)
                    
                    ZStack {
                        if viewModel.pictures.count > 1 {
                            TabView(selection: $viewModel.bottomSelection) {
                                ForEach(viewModel.models.indices, id: \.self) { index in
                                    ZStack(alignment: .bottomTrailing) {
                                        ImageScrollViewRepresentable(viewModel: viewModel.models[index])
                                        
                                        VStack {
                                            Text("\(dateFormatter.string(from: viewModel.models[index].photo.addDate!))")
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 5)
                                                .foregroundColor(.white)
                                        }
                                        .background(Color.black.opacity(0.4))
                                    }
                                    .tag(index)
                                }
                            }
                            .tabViewStyle(.page)
                            
                            HStack {
                                Button {
                                    if viewModel.bottomSelection > 0 {
                                        viewModel.bottomSelection = viewModel.bottomSelection - 1
                                    }
                                } label: {
                                    Image(systemName: "chevron.backward")
                                        .font(.system(size: 45, weight: .medium, design: .default))
                                }
                                
                                Spacer()
                                
                                Button {
                                    if viewModel.bottomSelection < viewModel.pictures.count - 1 {
                                        viewModel.bottomSelection = viewModel.bottomSelection + 1
                                    }
                                } label: {
                                    Image(systemName: "chevron.forward")
                                        .font(.system(size: 45, weight: .medium, design: .default))
                                }
                            }
                            .frame(height: geo.size.height/2 - 30, alignment: .center)
                            .padding(.horizontal)
                        }
                    }
                    .frame(height: geo.size.height/2 - 30, alignment: .center)
                }
                
                Button {
                    viewModel.navigation.present(.page) {
                        CameraScreenView(completionHandler: { photo in
                            
                        }, bodyPoint: bodyPoint)
                    } onDismiss: {
                        
                    }
                } label: {
                    VStack {
                        Image(systemName: "camera")
                            .font(.system(size: 24, weight: .medium, design: .default))
                            .foregroundColor(.white)
                    }
                    .frame(width: 50, height: 50, alignment: .center)
                    .background(Color.blue)
                    .cornerRadius(25)
                    .padding()
                }
            }
            .uses(viewModel.navigation)
            .frame(width: geo.size.width, height: geo.size.height)
            .navigationBarTitle("Compare", displayMode: .inline)
            .onAppear {
                viewModel.preparePhotos(bodyPoint)
            }
            .onDisappear {
                // save current photo zoom and contentOffset
                viewModel.saveData()
            }
        }
    }
}

struct ComparePhotoScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ComparePhotoScreenView(bodyPoint: BodyPoint())
    }
}
