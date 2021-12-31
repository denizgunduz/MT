//
//  ReminderSettingsScreenView.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 26.11.2021.
//

import Foundation
import SwiftUI
import RadioGroup

struct ReminderSettingsScreenView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ViewModel = ViewModel()
    var body: some View {
        VStack {
            Form {
                RadioGroupPicker(selectedIndex: $viewModel.selection, titles: ["Every Month", "Every 2 Months", "Every 3 Months", "Every 6 Months", "Every 12 Months", "Every 2 mins"]) // Evey 2 minutes only for testing purpose
                    .spacing(24)
                    .fixedSize()
                
                HStack {
                    Spacer()
                    Button("Save") {
                        self.viewModel.saveReminderSelection()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear(perform: {
            self.viewModel.checkSettings()
        })
        .navigationBarTitle(Text("Reminders"),
                            displayMode: .inline)
    }
}

struct ReminderSettingsScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReminderSettingsScreenView()
        }
    }
}
