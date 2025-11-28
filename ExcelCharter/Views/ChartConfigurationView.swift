//
//  ChartConfigurationView.swift
//  ExcelCharter
//
//  View for configuring chart settings and previewing data
//

import SwiftUI
import Charts

struct ChartConfigurationView: View {
    // MARK: - Properties
    let sheetFile: SheetFile
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel = ChartViewModel()
    @State private var showChart = false
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Chart Type Selection
                Section {
                    Picker("Chart Type", selection: $viewModel.chartType) {
                        ForEach(ChartType.allCases) { type in
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(type.rawValue)
                                        .font(.body)
                                    Text(type.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                Image(systemName: type.systemImage)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("Chart Type")
                } footer: {
                    Text("Select how you want to visualize your data")
                }
                
                // MARK: - X-Axis Configuration
                Section {
                    Picker("Column", selection: $viewModel.xAxisColumn) {
                        ForEach(viewModel.columnNames.indices, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.columnNames[index])
                                    .font(.body)
                                Text(viewModel.getColumnTypeDescription(columnIndex: index))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(index)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .onChange(of: viewModel.xAxisColumn) { _, _ in
                        validateData()
                    }
                    
                    // Preview of X-axis data
                    if !viewModel.columnNames.isEmpty && viewModel.columnNames.indices.contains(viewModel.xAxisColumn) {
                        ColumnPreviewRow(
                            title: "Preview",
                            values: viewModel.getColumnPreview(
                                data: sheetFile.data ?? [],
                                columnIndex: viewModel.xAxisColumn
                            )
                        )
                    }
                } header: {
                    HStack {
                        Text("X-Axis (Categories)")
                        Spacer()
                        Image(systemName: "arrow.right")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                } footer: {
                    Text("Choose the column for horizontal axis labels")
                }
                
                // MARK: - Y-Axis Configuration
                Section {
                    Picker("Column", selection: $viewModel.yAxisColumn) {
                        ForEach(viewModel.columnNames.indices, id: \.self) { index in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(viewModel.columnNames[index])
                                        .font(.body)
                                    Text(viewModel.getColumnTypeDescription(columnIndex: index))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                // Show indicator if column is not numeric
                                if !viewModel.isColumnValidForYAxis(columnIndex: index) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.orange)
                                        .font(.caption)
                                }
                            }
                            .tag(index)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .onChange(of: viewModel.yAxisColumn) { _, _ in
                        validateData()
                    }
                    
                    // Preview of Y-axis data
                    if !viewModel.columnNames.isEmpty && viewModel.columnNames.indices.contains(viewModel.yAxisColumn) {
                        ColumnPreviewRow(
                            title: "Preview",
                            values: viewModel.getColumnPreview(
                                data: sheetFile.data ?? [],
                                columnIndex: viewModel.yAxisColumn
                            )
                        )
                    }
                } header: {
                    HStack {
                        Text("Y-Axis (Values)")
                        Spacer()
                        Image(systemName: "arrow.up")
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                } footer: {
                    Text("Choose the column with numeric values to plot")
                }
                
                // MARK: - Validation Status
                Section {
                    if let errorMessage = viewModel.errorMessage {
                        Label {
                            Text(errorMessage)
                                .font(.callout)
                        } icon: {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    } else if viewModel.isDataValid {
                        Label {
                            Text("Configuration is valid")
                                .font(.callout)
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                        
                        // Show data point count
                        let dataPoints = viewModel.prepareChartData(from: sheetFile.data ?? [])
                        HStack {
                            Text("Data Points")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(dataPoints.count)")
                                .bold()
                        }
                    }
                }
                
                // MARK: - Chart Preview Section
                if viewModel.isDataValid {
                    Section {
                        ChartPreviewView(
                            viewModel: viewModel,
                            data: sheetFile.data ?? []
                        )
                        .frame(height: 250)
                    } header: {
                        Text("Preview")
                    }
                }
            }
            .navigationTitle("Configure Chart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create Chart") {
                        showChart = true
                    }
                    .disabled(!viewModel.isDataValid)
                    .bold()
                }
            }
            .onAppear {
                initializeViewModel()
            }
            .sheet(isPresented: $showChart) {
                FullChartView(
                    viewModel: viewModel,
                    sheetFile: sheetFile
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func initializeViewModel() {
        guard let data = sheetFile.data else { return }
        viewModel.initialize(with: data)
        validateData()
    }
    
    private func validateData() {
        guard let data = sheetFile.data else { return }
        _ = viewModel.validateSelection(data: data)
    }
}

// MARK: - Supporting Views

struct ColumnPreviewRow: View {
    let title: String
    let values: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if values.isEmpty {
                Text("No data available")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                Text(values.joined(separator: ", "))
                    .font(.caption)
                    .lineLimit(2)
            }
        }
    }
}

struct ChartPreviewView: View {
    let viewModel: ChartViewModel
    let data: [[String]]
    
    var body: some View {
        let chartData = viewModel.prepareChartData(from: data)
        let xAxisLabel = viewModel.columnNames.indices.contains(viewModel.xAxisColumn)
            ? viewModel.columnNames[viewModel.xAxisColumn]
            : "X"
        let yAxisLabel = viewModel.columnNames.indices.contains(viewModel.yAxisColumn)
            ? viewModel.columnNames[viewModel.yAxisColumn]
            : "Y"
        
        VStack {
            if chartData.isEmpty {
                ContentUnavailableView(
                    "No Data",
                    systemImage: "chart.bar.xaxis",
                    description: Text("No valid data points to display")
                )
            } else {
                Chart(chartData) { point in
                    switch viewModel.chartType {
                    case .bar:
                        BarMark(
                            x: .value(xAxisLabel, point.x),
                            y: .value(yAxisLabel, point.y)
                        )
                        .foregroundStyle(.blue.gradient)
                        
                    case .line:
                        LineMark(
                            x: .value(xAxisLabel, point.x),
                            y: .value(yAxisLabel, point.y)
                        )
                        .foregroundStyle(.blue)
                        .symbol(.circle)
                        
                    case .point:
                        PointMark(
                            x: .value(xAxisLabel, point.x),
                            y: .value(yAxisLabel, point.y)
                        )
                        .foregroundStyle(.blue)
                        
                    case .area:
                        AreaMark(
                            x: .value(xAxisLabel, point.x),
                            y: .value(yAxisLabel, point.y)
                        )
                        .foregroundStyle(.blue.gradient)
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .aligned)
                }
                .chartYAxis {
                    AxisMarks(preset: .aligned)
                }
            }
        }
        .padding()
    }
}

struct FullChartView: View {
    let viewModel: ChartViewModel
    let sheetFile: SheetFile
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Chart Info
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(label: "Chart Type", value: viewModel.chartType.rawValue)
                            InfoRow(
                                label: "X-Axis",
                                value: viewModel.columnNames[viewModel.xAxisColumn]
                            )
                            InfoRow(
                                label: "Y-Axis",
                                value: viewModel.columnNames[viewModel.yAxisColumn]
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    // Full Chart
                    ChartPreviewView(
                        viewModel: viewModel,
                        data: sheetFile.data ?? []
                    )
                    .frame(height: 400)
                    .padding()
                }
            }
            .navigationTitle(sheetFile.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ChartConfigurationView(
        sheetFile: SheetFile(
            title: "Sample.csv",
            data: [
                ["Month", "Sales", "Expenses"],
                ["January", "1000", "500"],
                ["February", "1500", "600"],
                ["March", "1200", "550"],
                ["April", "1800", "700"]
            ],
            fileExtension: "csv"
        )
    )
}