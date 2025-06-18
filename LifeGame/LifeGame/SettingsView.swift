import SwiftUI
import AudioToolbox
import CoreHaptics
import AVFoundation
import CellGridView
import Utils

struct SettingsView: View
{
    @EnvironmentObject var cellGridView: LifeCellGridView
    @EnvironmentObject var settings: Settings

    let iconWidth: CGFloat = 32

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "puzzlepiece.fill").frame(width: iconWidth, alignment: .leading)
                        Text("Cell Shape").alignmentGuide(.leading) { d in d[.leading] }
                        Picker("", selection: $settings.cellShape) {
                            ForEach(CellShape.allCases) { value in
                                Text(value.rawValue).lineLimit(1).truncationMode(.tail).tag(value)
                            }
                        }
                        .pickerStyle(.menu).disabled(settings.cellSize < 6)
                    }
                    HStack(alignment: .firstTextBaseline) {
                        Image(systemName: "magnifyingglass").frame(width: iconWidth, alignment: .leading)
                        Text("Cell Size").alignmentGuide(.leading) { d in d[.leading] }
                        Spacer()
                        Text("\(settings.cellSize)").foregroundColor(.secondary)
                    }.padding(.bottom, 8)
                    Slider(
                        value: Binding(get: { Double(settings.cellSize) }, set: { settings.cellSize = Int($0) }),
                                       in: Double(cellGridView.minimumCellSize)...Double(cellGridView.maximumCellSize), step: 1)
                        .padding(.top, -8).padding(.bottom, -2)
                        .onChange(of: settings.cellSize) { newValue in settings.cellSize = newValue }
                }
                VStack {
                    // HStack {
                    //     Image(systemName: "play.circle").frame(width: iconWidth, alignment: .leading)
                    //     Text("Automation").alignmentGuide(.leading) { d in d[.leading] }
                    //     Spacer()
                    //     Toggle("", isOn: $settings.automationEnabled).labelsHidden()
                    // }
                    HStack {
                        Image(systemName: "sparkles").frame(width: iconWidth, alignment: .leading)
                        Text("Automation Speed").alignmentGuide(.leading) { d in d[.leading] }
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
            }
            Section(header: Text("COLORS").padding(.leading, -12).padding(.top, -20)) {
                HStack {
                    HStack {
                        ColorCircleIcon().frame(width: iconWidth, alignment: .leading)
                        Text("Active").alignmentGuide(.leading) { d in d[.leading] }
                        Spacer()
                    }
                    ColorPicker("", selection: $settings.activeColorInternal)
                        .onChange(of: settings.activeColorInternal) { newValue in
                           settings.activeColorInternal = newValue
                        }
                }
                HStack {
                    HStack {
                        ColorCircleIcon().frame(width: iconWidth, alignment: .leading)
                        Text("Inactive").alignmentGuide(.leading) { d in d[.leading] }
                        Spacer()
                    }
                    ColorPicker("", selection: $settings.inactiveColorInternal)
                        .onChange(of: settings.inactiveColorInternal) { value in
                           settings.inactiveColorInternal = value
                        }
                }
                HStack {
                    Image(systemName: "number").frame(width: iconWidth, alignment: .leading)
                    Text("Inactive Random").alignmentGuide(.leading) { d in d[.leading] }
                    Spacer()
                    Toggle("", isOn: $settings.inactiveColorRandom).labelsHidden()
                }
                HStack {
                    Image(systemName: "circle.grid.cross").frame(width: iconWidth, alignment: .leading)
                    Text("Inactive Dynamic").alignmentGuide(.leading) { d in d[.leading] }
                    Spacer()
                    Toggle("", isOn: $settings.inactiveColorRandomDynamic).labelsHidden()
                }.disabled(!settings.inactiveColorRandom)
                HStack {
                    Image(systemName: "paintpalette").frame(width: iconWidth, alignment: .leading)
                    Text("Inactive Color Mode").alignmentGuide(.leading) { d in d[.leading] }
                    Picker("", selection: $settings.inactiveColorRandomColorMode) {
                        ForEach(ColourMode.allCases) { mode in
                            Text(mode.rawValue)
                                .lineLimit(1)
                                // .truncationMode(.tail)
                                .tag(mode)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: settings.inactiveColorRandomColorMode) { newValue in
                        settings.inactiveColorRandomColorMode = newValue
                    }
                }.disabled(!settings.inactiveColorRandom)
                HStack {
                    HStack {
                        ColorCircleIcon()
                        Text("Background")
                            .padding(.leading, 8)
                            .frame(width: 152)
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
    var activeColorInternal: Color {
        get { Color(self.activeColor) }
        set { self.activeColor = Colour(newValue) }
    }
    var inactiveColorInternal: Color {
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
