//
//  AddNewUserScreenView.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 26.11.2021.
//

import SwiftUI

struct AddNewUserScreenView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ProfilesScreenView.ViewModel
    var body: some View {
        VStack {
            Form {
                TextField("Please enter user name", text: $viewModel.userName)
            }
        }
        .uses(viewModel.navigation)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Cancel")
        }), trailing: Button(action: {
            viewModel.saveUser()
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Save")
        }))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text("Add New User"), displayMode: .inline)
    }
}

struct AddNewUserScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddNewUserScreenView(viewModel: ProfilesScreenView.ViewModel())
        }
    }
}
