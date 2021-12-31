//
//  ListScreenView.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 27.11.2021.
//

import SwiftUI

struct ListScreenView: View {
    @ObservedObject var viewModel = ViewModel()
    var body: some View {
        VStack {
            List(viewModel.points) { point in
                Button(action: {
                    viewModel.navigation.present(.page) {
                        ComparePhotoScreenView(bodyPoint: point)
                    } onDismiss: {
                        viewModel.fetchPoints()
                    }
                }, label: {
                    HStack {
                        if point.preview != nil,
                            let image = UIImage.init(data: point.preview!) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 70, height: 70, alignment: .center)
                        }
                        else {
                            VStack {
                                
                            }
                            .frame(width: 70, height: 70, alignment: .center)
                            .background(Color.gray.opacity(0.3))
                        }
                        
                        VStack(alignment: .leading) {
                            Text("\(point.sideType == 1 ? "Front" : "Back")")
                            let diff = viewModel.calculateLeftDays(point)
                            if diff > 0 {
                                Text("Next photo in \(diff) days")
                            }
                            else {
                                Text("You should take a photo")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 20, weight: .medium, design: .default))
                    }
                })
                .padding(5)
                .swipeActions {
                    Button("Delete", role: .destructive) {
                        viewModel.delete(point)
                    }
                }
            }
        }
        .uses(viewModel.navigation)
        .navigationBarTitle(Text("Photolog"), displayMode: .inline)
    }
}

struct ListScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ListScreenView()
    }
}
