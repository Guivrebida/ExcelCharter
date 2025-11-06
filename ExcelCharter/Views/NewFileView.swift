//
//  NewFileView.swift
//  ExcelCharter
//
//  Created by Paradis d'Abbadon on 05.11.25.
//
//  Will display small popup window prompting user to
//  name imported file. Also accesses Filesystem to
//  locate .csv files to import.
//

import SwiftUI

struct NewFileView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var newFileName: String = ""
    @FocusState private var newFileFieldIsFocused: Bool
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("File Name", text: $newFileName)
                    .focused($newFileFieldIsFocused)
                    .onSubmit {
                        saveFile()
                    }
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                ///Temporary addition to preview filename
                Text("\(newFileName).csv")
                    .foregroundColor(newFileFieldIsFocused ? .red : .blue)
                    
                Spacer()
            }
            .navigationTitle("Add New File")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveFile()
                    }
                    .disabled(newFileName.isEmpty)
                }
            }
        }
        .onAppear {
            newFileFieldIsFocused = true
        }
    }
        
    private func saveFile() {
        guard !newFileName.isEmpty else { return }
        // Add save logic here
        print("Saving file: \(newFileName)")
        dismiss()
    }
}

#Preview {
    NewFileView()
}
