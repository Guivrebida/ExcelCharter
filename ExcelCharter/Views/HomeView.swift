//
//  ContentView.swift
//  ExcelCharter
//
//  Created by Paradis d'Abbadon on 05.11.25.
//

import SwiftUI
import UniformTypeIdentifiers

struct HomeView: View {
    // MARK: - Properties
    @State private var viewModel = FileImportViewModel()
    @State private var showFileImporter = false
    
    var body: some View {
        // MARK: - Body
        NavigationStack {
            List {
                ForEach(viewModel.sheetfiles) { sheetfile in
                    NavigationLink {
                        Text("Temporary")
                    } label: {
                        Text(sheetfile.title)
                            .font(.title2)
                    }
                }
            }
            .navigationTitle("Home")
            .listStyle(.plain)
        }
        HStack {
            Button(action: {
                print("search button tapped")
            }) {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 20, height: 22)
            }
            .buttonStyle(.borderedProminent)
            .shadow(radius: 5)
            .tint(.gray)
            
            Button("Add File") {
                showFileImporter = true
            }
            .buttonStyle(.borderedProminent)
            .shadow(radius: 5)
            .bold()
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.commaSeparatedText, .spreadsheet],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result: result)
        }
    }
    // MARK: - Helper Methods
    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            guard url.startAccessingSecurityScopedResource() else {
                print("Couldn't access file")
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            viewModel.importFile(from: url)
            
        case .failure(let error):
            print("File import error: \(error.localizedDescription)")
        }
    }
}
// MARK: - Preview
#Preview {
    HomeView()
}
