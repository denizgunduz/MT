//
//  LoginScreenView.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 25.11.2021.
//

import SwiftUI

struct LoginScreenView: View {
    @ObservedObject var viewModel: ViewModel = ViewModel()
    var body: some View {
        VStack {
            Spacer()
            
            Text("SkinTracker")
                .fontWeight(.heavy)
                .font(.system(size: 32))
            
            Form {
                TextField("Please enter user name", text: $viewModel.userName)
                
                HStack {
                    Spacer()
                    Button("Continue") {
                        viewModel.saveUser {
                            viewModel.navigation.present(.page) {
                                HomeScreenView()
                            } onDismiss: {
                                
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
        .navigationBarHidden(true)
    }
}

struct LoginScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreenView()
    }
}
