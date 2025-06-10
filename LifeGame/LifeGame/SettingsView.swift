import SwiftUI
import AudioToolbox
import CoreHaptics
import AVFoundation
import CellGridView

struct SettingsView: View
{
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var cellGridView: CellGridView

    var body: some View {
        Form {
            Section(header: Text("CELLS").padding(.leading, -12)) {
                HStack {
                    Label("Color Mode", systemImage: "paintpalette")
                    Picker("", selection: $settings.cellColorMode) {
                        ForEach(CellColorMode.allCases) { mode in
                            Text(mode.rawValue)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: settings.cellColorMode) { newValue in
                        settings.cellColorMode = newValue
                    }
                }
                HStack {
                    Label("Cell Shape", systemImage: "puzzlepiece.fill")
                    Picker("", selection: $settings.cellShape) {
                        ForEach(CellShape.allCases) { mode in
                            Text(mode.rawValue)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(settings.cellSize < 6)
                }
                VStack {
                    HStack {
                        Label("Cells Size", systemImage: "magnifyingglass")
                        Spacer()
                        Text("\(settings.cellSize)")
                    }
                    Slider(
                        value: Binding(
                            get: { Double(settings.cellSize) },
                            set: { settings.cellSize = Int($0) }
                        ),
                        in: 1...50, step: 1)
                        .padding(.top, -8)
                        .padding(.bottom, -2)
                    .onChange(of: settings.cellSize) { newValue in
                        settings.cellSize = newValue
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DeveloperSettingsView: View {

    @EnvironmentObject var settings: Settings

    var body: some View {
        Form {
            Section(header: Text("CELLS").padding(.leading, -12)) {
            }
        }
        .onAppear {
        }
        .navigationTitle("Advanced")
        .navigationBarTitleDisplayMode(.inline)
    }
}
