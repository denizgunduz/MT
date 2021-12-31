//
//  ProfilesScreenView.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 26.11.2021.
//

import SwiftUI

struct ProfilesScreenView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ViewModel = ViewModel()
    var body: some View {
        ZStack {
            VStack {
                List {
                    Section(header: Text("Main User")) {
                        if let mainUser = viewModel.users.first { u in
                            u.isSubUser == false
                        } {
                            Button {
                                SkinTrackerAppManager.shared.selectedUser = mainUser
                                viewModel.updateUser(mainUser)
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text(mainUser.name ?? "Unknown")
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    viewModel.delete(mainUser)
                                }
                                
                                Button("Update Name") {
                                    viewModel.selectedUser = mainUser
                                    viewModel.userName = mainUser.name ?? ""
                                    viewModel.navigation.present(.page) {
                                        UpdateUserScreenView(viewModel: viewModel)
                                    } onDismiss: {
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Sub Users")) {
                        let subUsers = viewModel.users.filter { u in
                            u.isSubUser == true
                        }
                        ForEach(subUsers) { user in
                            Button {
                                SkinTrackerAppManager.shared.selectedUser = user
                                viewModel.updateUser(user)
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Text(user.name ?? "Unknown")
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    viewModel.delete(user)
                                }
                                
                                Button("Update Name") {
                                    viewModel.selectedUser = user
                                    viewModel.userName = user.name ?? ""
                                    viewModel.navigation.present(.page) {
                                        UpdateUserScreenView(viewModel: viewModel)
                                    } onDismiss: {
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .alert(viewModel.alertMessage, isPresented: $viewModel.alertShowing) {
            Button("Cancel", role: .cancel) { }
        }
        .uses(viewModel.navigation)
        .navigationBarItems(trailing: Button(action: {
            viewModel.navigation.present(.page) {
                AddNewUserScreenView(viewModel: viewModel)
            } onDismiss: {
                
            }
        }, label: {
            Text("Add New Profile")
        }))
        .navigationBarTitle(Text("Profiles"), displayMode: .inline)
    }
}

struct ProfilesScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfilesScreenView()
        }
    }
}
