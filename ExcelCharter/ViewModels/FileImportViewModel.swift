//
//  FileImportViewModel.swift
//  ExcelCharter
//
//  Created by Paradis d'Abbadon on 10.11.25.
//

import Foundation
import CoreXLSX

@Observable
class FileImportViewModel {
    var sheetfiles: [SheetFile] = [
        SheetFile(id: UUID(), title: "Sheet 1"),
        SheetFile(id: UUID(), title: "Sheet 2"),
        SheetFile(id: UUID(), title: "Sheet 3")
    ]
    
    // MARK: - Methods
    func importFile(from url: URL) {
        let fileName = url.lastPathComponent
        let fileExtension = url.pathExtension.lowercased()
        
        if fileExtension == "csv" {
            processCSV(url: url, fileName: fileName)
        } else if fileExtension == "xlsx" || fileExtension == "xls" {
            processExcel(url: url, fileName: fileName)
        }
    }
    
    private func processCSV(url: URL, fileName: String) {
        do {
            let csvString = try String(contentsOf: url, encoding: .utf8)
            let rows = csvString.components(separatedBy: .newlines)
            
            print("CSV has \(rows.count) rows")
            
            let newSheet = SheetFile(id: UUID(), title: fileName)
            sheetfiles.append(newSheet)
            
            for (index, row) in rows.prefix(5).enumerated() {
                print("Row \(index): \(row)")
            }
        } catch {
            print("Error reading CSV: \(error)")
        }
    }
    
    private func processExcel(url: URL, fileName: String) {
        do {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: tempURL)
            try FileManager.default.copyItem(at: url, to: tempURL)
            
            guard let file = XLSXFile(filepath: tempURL.path) else {
                print("Failed to open Excel file")
                return
            }
            
            let worksheetPaths = try file.parseWorksheetPaths()
            let sharedStrings = try file.parseSharedStrings()
            
            for path in worksheetPaths {
                let worksheet = try file.parseWorksheet(at: path)
                
                if let rows = worksheet.data?.rows {
                    for (rowIndex, row) in rows.prefix(5).enumerated() {
                        var rowValues: [String] = []
                        
                        for cell in row.cells {
                            let cellValue: String
                            if let sharedStrings = sharedStrings {
                                cellValue = cell.stringValue(sharedStrings) ?? ""
                            } else {
                                cellValue = cell.value ?? ""
                            }
                            rowValues.append(cellValue)
                        }
                        print("Row \(rowIndex): \(rowValues.joined(separator: ", "))")
                    }
                }
            }
            
            let newSheet = SheetFile(id: UUID(), title: fileName)
            sheetfiles.append(newSheet)
            
            try? FileManager.default.removeItem(at: tempURL)
        } catch {
            print("Error reading Excel file: \(error)")
        }
    }
}
