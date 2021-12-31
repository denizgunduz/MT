//
//  UpdateUserScreenView.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 12.12.2021.
//

import SwiftUI

struct UpdateUserScreenView: View {
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
            viewModel.selectedUser?.name = viewModel.userName
            viewModel.updateUsers()
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Save")
        }))
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle(Text("Update User"), displayMode: .inline)
    }
}

struct UpdateUserScreenView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateUserScreenView(viewModel: ProfilesScreenView.ViewModel())
    }
}
