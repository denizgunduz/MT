//
//  HomeScreenView.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 25.11.2021.
//

import SwiftUI

struct HomeScreenView: View {
    @ObservedObject var viewModel: ViewModel = ViewModel()
    @State var userName: String = ""
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        VStack {
            Button {
                viewModel.navigation.present(.page) {
                    ListScreenView()
                } onDismiss: {
                    
                }
            } label: {
                HStack {
                    Image(systemName: "list.bullet")
                    Text("Open List")
                }
            }
            HStack {
                Button {
                    viewModel.isFrontSide = true
                    viewModel.fetchPoints(1)
                } label: {
                    Text("Front")
                        .foregroundColor(viewModel.isFrontSide ? Color.primary : Color.primary.opacity(0.5))
                }
                
                Spacer()
                    .frame(width: 1, height: 30, alignment: .center)
                    .background(Color.gray)
                    .padding()
                
                Button {
                    viewModel.isFrontSide = false
                    viewModel.fetchPoints(2)
                } label: {
                    Text("Back")
                        .foregroundColor(!viewModel.isFrontSide ? Color.primary : Color.primary.opacity(0.5))
                }
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                //960 2193
                BodyMapViewRepresantable(savedPoints: $viewModel.bodyPoints, viewModel: viewModel) { point, image in
                    viewModel.touchPoint = point
                    viewModel.previewImage = image
                }.frame(width: UIScreen.main.bounds.width,
                           height: ((UIScreen.main.bounds.width) * 2193) / 960, alignment: .center)
            }
            
            Button {
                if viewModel.touchPoint != nil {
                    // new photo
                    viewModel.navigation.present(.page) {
                        CameraScreenView(completionHandler: { photo in
                            
                        }, point: viewModel.touchPoint!,
                                         sideType: viewModel.isFrontSide ? 1 : 2,
                                         previewImage: viewModel.previewImage)
                    } onDismiss: {
                        
                    }
                }
                else {
                    viewModel.alertMessage = "You should select a position"
                    viewModel.alertShowing = true
                }
            } label: {
                HStack {
                    Text("Choose New Area")
                        .foregroundColor(.white)
                }
                .frame(width: UIScreen.main.bounds.width * 0.9, height: 50, alignment: .center)
                .background(Color.blue)
                .cornerRadius(16)
            }
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.alertShowing) {
            Button("Cancel", role: .cancel) { }
        }
        .uses(viewModel.navigation)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            viewModel.navigation.present(.page) {
                ProfilesScreenView()
            } onDismiss: {
                userName = SkinTrackerAppManager.shared.selectedUser.name ?? ""
            }
        }, label: {
            Text("Profiles")
        }), trailing: Button(action: {
            viewModel.navigation.present(.page) {
                ReminderSettingsScreenView()
            } onDismiss: {
                
            }
        }, label: {
            Text("Reminders")
        }))
        .navigationBarTitle("\(userName)'s Skin")
        .onAppear {
            userName = SkinTrackerAppManager.shared.selectedUser.name ?? ""
            
            if userName.isEmpty {
                viewModel.navigation.present(.page) {
                    LoginScreenView()
                } onDismiss: {
                    
                }
            }
            
            viewModel.touchPoint = nil
            viewModel.previewImage = nil
            viewModel.fetchPoints(self.viewModel.isFrontSide ? 1 : 2)
            
            if SkinTrackerAppManager.shared.redirectUser {
                SkinTrackerAppManager.shared.redirectUser = false
                viewModel.navigation.present(.page) {
                    ListScreenView()
                } onDismiss: {
                    
                }
            }
        }
        .onDisappear {
            viewModel.delegate?.deleteNewPoint()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if SkinTrackerAppManager.shared.redirectUser {
                    SkinTrackerAppManager.shared.redirectUser = false
                    viewModel.navigation.present(.page) {
                        ListScreenView()
                    } onDismiss: {
                        
                    }
                }
            }
        }
    }
}

struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeScreenView()
        }
    }
}
