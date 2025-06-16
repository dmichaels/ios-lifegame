import SwiftUI
import AudioToolbox
import CoreHaptics
import AVFoundation
import CellGridView
import Utils

struct SettingsView: View
{
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var cellGridView: CellGridView

    var body: some View {
        Form {
            Section(/* header: Text("CELLS").padding(.leading, -12) */ ) {
                HStack {
                    Label("Cell Shape", systemImage: "puzzlepiece.fill")
                    Picker("", selection: $settings.cellShape) {
                        ForEach(CellShape.allCases) { value in
                            Text(value.rawValue)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                    .disabled(settings.cellSize < 6)
                }
                VStack {
                    HStack {
                        Label("Cell Size", systemImage: "magnifyingglass")
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
                HStack {
                    HStack {
                        ColorCircleIcon()
                        Text("Background Color")
                            .padding(.leading, 8)
                            .frame(width: 152) // TODO: only need to stop wrapping; need better way.
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .layoutPriority(1)
                        Spacer()
                    }
                    ColorPicker("", selection: $settings.viewBackgroundInternal)
                        .onChange(of: settings.viewBackgroundInternal) { newValue in
                           settings.viewBackgroundInternal = newValue
                        }
                }
                HStack {
                    // Label("Inactive Color Mode", systemImage: "paintpalette")
                    Image(systemName: "paintpalette")
                        .foregroundColor(.accentColor)
                    Text("Inactive Cell Color Mode")
                        .frame(width: 212) // TODO: only need to stop wrapping; need better way.
                    Picker("", selection: $settings.inactiveColorRandomColorMode) {
                        ForEach(ColourMode.allCases) { mode in
                            Text(mode.rawValue)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: settings.inactiveColorRandomColorMode) { newValue in
                        settings.inactiveColorRandomColorMode = newValue
                    }
                }
                HStack {
                    Label("Inactive Cell Color Random", systemImage: "questionmark.app.dashed")
                    Spacer()
                    Toggle("", isOn: $settings.inactiveColorRandom)
                        .labelsHidden()
                }
                HStack {
                    Label("Inactive Cell Color Dynamic", systemImage: "circle.grid.cross")
                    Spacer()
                    Toggle("", isOn: $settings.inactiveColorRandomDynamic)
                        .labelsHidden()
                }
                HStack {
                    HStack {
                        ColorCircleIcon()
                        Text("Active Cell Color")
                            .padding(.leading, 0)
                            .frame(width: 152) // TODO: only need to stop wrapping; need better way.
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .layoutPriority(1)
                        Spacer()
                    }
                    ColorPicker("", selection: $settings.cellActiveColorInternal)
                        .onChange(of: settings.cellActiveColorInternal) { newValue in
                           settings.cellActiveColorInternal = newValue
                        }
                }
                VStack {
                    HStack {
                        Label("Automation", systemImage: "play.circle")
                        Spacer()
                        Toggle("", isOn: $settings.automationEnabled)
                            .labelsHidden()
                    }
                    HStack {
                        Label("Automation Speed", systemImage: "sparkles")
                            .lineLimit(1)
                            .layoutPriority(1)
                        Spacer()
                        Picker("", selection: $settings.automationInterval) {
                            ForEach(AutomationIntervalOptions, id: \.value) { option in
                                Text(option.label)
                                    .tag(option.value)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .disabled(!settings.automationEnabled)
                    }
                }
                //
                // Experiment showing only preferred sizes ...
                //
                // HStack {
                //     Label("Cell Size", systemImage: "puzzlepiece.fill")
                //     Picker("", selection: $settings.cellSize) {
                //         ForEach(self.cellGridView.preferredCellSizes, id: \.self) { value in
                //             Text("\(value)").tag(value)
                //                 .lineLimit(1)
                //                 .truncationMode(.tail)
                //                 .tag(value)
                //         }
                //     }
                //     .pickerStyle(.menu)
                // }
            }
        }
        .offset(y: -30)
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

extension Settings {
    var viewBackgroundInternal: Color {
        get { Color(self.viewBackground) }
        set { self.viewBackground = Colour(newValue) }
    }
    var cellActiveColorInternal: Color {
        get { Color(self.activeColor) }
        set { self.activeColor = Colour(newValue) }
    }
    var cellInactiveColorInternal: Color {
        get { Color(self.inactiveColor) }
        set { self.inactiveColor = Colour(newValue) }
    }
}

let AutomationIntervalOptions: [(label: String, value: Double)] = [
    ("Slowest", 7.0),
    ("Slower", 3.0),
    ("Slow", 2.0),
    ("Medium", 1.0),
    ("Default", 0.5),
    ("Fast", 0.3),
    ("Faster", 0.2),
    ("Fastest", 0.1),
    ("Wow", 0.05),
    ("Max", 0.0)
]
