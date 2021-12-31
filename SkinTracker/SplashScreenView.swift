//
//  SplashScreenView.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 25.11.2021.
//

import SwiftUI

struct SplashScreenView: View {
    @ObservedObject var viewModel: ViewModel = ViewModel()
    var body: some View {
        VStack {
            Spacer()
            
            Text("SkinTracker")
                .fontWeight(.heavy)
                .font(.system(size: 32))
                
            Spacer()
        }
        .uses(viewModel.navigation)
        .frame(width: UIScreen.main.bounds.width)
        .onAppear {
            // check core data
            viewModel.initApp { hasUser in
                if hasUser {
                    viewModel.navigation.present(.page) {
                        HomeScreenView()
                    } onDismiss: {
                        
                    }
                }
                else {
                    viewModel.navigation.present(.page) {
                        LoginScreenView()
                    } onDismiss: {
                        
                    }
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
