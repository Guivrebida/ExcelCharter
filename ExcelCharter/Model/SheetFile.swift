//
//  SheetFile.swift
//  ExcelCharter
//
//  Created by Paradis d'Abbadon on 05.11.25.
//
//  Model detailing how .csv file
//  data will be handled when imported
//

import Foundation

struct SheetFile: Identifiable {
    let id: UUID
    var title: String
    var url: URL?
    // Spreadsheet data stored in 2D array (data)
    var data: [[String]]?
    
    init(id: UUID, title: String, data: [[String]]? = nil) {
        //custom initializer to allow for data to be nil
           self.id = id
           self.title = title
           self.data = data
       }
}
