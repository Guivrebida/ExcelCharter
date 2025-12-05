//
//  DataFilterView.swift
//  ExcelCharter
//
//  View for selecting which rows to include/exclude from chart
//

import SwiftUI

struct DataFilterView: View {
    let data: [[String]]
    let xAxisColumn: Int
    let yAxisColumn: Int
    @Binding var excludedRowIndices: Set<Int>
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectAll = true
    
    var columnNames: [String] {
        data.first ?? []
    }
    
    var dataRows: [(index: Int, row: [String])] {
        Array(data.enumerated().dropFirst()) // Skip header
    }
    
    var selectedCount: Int {
        dataRows.count - excludedRowIndices.count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Summary bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(selectedCount) of \(dataRows.count) rows selected")
                            .font(.headline)
                        Text("Deselected rows will be excluded from the chart")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Button {
                        toggleSelectAll()
                    } label: {
                        Text(selectAll ? "Deselect All" : "Select All")
                            .font(.subheadline)
                            .bold()
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                
                Divider()
                
                // Data rows list
                List {
                    ForEach(dataRows, id: \.index) { item in
                        DataRowCell(
                            rowNumber: item.index,
                            row: item.row,
                            xColumn: xAxisColumn,
                            yColumn: yAxisColumn,
                            columnNames: columnNames,
                            isSelected: !excludedRowIndices.contains(item.index)
                        ) {
                            toggleRow(item.index)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Select Data Rows")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.plain)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .bold()
                }
            }
            .onAppear {
                updateSelectAllState()
            }
        }
    }
    
    private func toggleRow(_ index: Int) {
        if excludedRowIndices.contains(index) {
            excludedRowIndices.remove(index)
        } else {
            excludedRowIndices.insert(index)
        }
        updateSelectAllState()
    }
    
    private func toggleSelectAll() {
        if selectAll {
            // Deselect all
            excludedRowIndices = Set(dataRows.map { $0.index })
        } else {
            // Select all
            excludedRowIndices.removeAll()
        }
        updateSelectAllState()
    }
    
    private func updateSelectAllState() {
        selectAll = excludedRowIndices.isEmpty
    }
}

struct DataRowCell: View {
    let rowNumber: Int
    let row: [String]
    let xColumn: Int
    let yColumn: Int
    let columnNames: [String]
    let isSelected: Bool
    let onToggle: () -> Void
    
    var xValue: String {
        row.indices.contains(xColumn) ? row[xColumn] : "—"
    }
    
    var yValue: String {
        row.indices.contains(yColumn) ? row[yColumn] : "—"
    }
    
    var xLabel: String {
        columnNames.indices.contains(xColumn) ? columnNames[xColumn] : "X"
    }
    
    var yLabel: String {
        columnNames.indices.contains(yColumn) ? columnNames[yColumn] : "Y"
    }
    
    var body: some View {
        Button {
            onToggle()
        } label: {
            HStack(spacing: 12) {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? .blue : .gray)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Row number
                    Text("Row \(rowNumber)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // Data values
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(xLabel)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(xValue)
                                .font(.body)
                                .bold()
                                .lineLimit(1)
                        }
                        
                        Divider()
                            .frame(height: 30)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(yLabel)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(yValue)
                                .font(.body)
                                .bold()
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
            .opacity(isSelected ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var excludedRows: Set<Int> = []
    
    DataFilterView(
        data: [
            ["Month", "Sales", "Expenses"],
            ["January", "1000", "500"],
            ["February", "1500", "600"],
            ["March", "1200", "550"],
            ["April", "1800", "700"],
            ["May", "2000", "750"]
        ],
        xAxisColumn: 0,
        yAxisColumn: 1,
        excludedRowIndices: $excludedRows
    )
}