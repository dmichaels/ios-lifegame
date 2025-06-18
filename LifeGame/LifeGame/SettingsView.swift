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
                    HStack {
                        IconLabel("Cell Shape", "puzzlepiece.fill")
                        Picker("", selection: $settings.cellShape) {
                            ForEach(CellShape.allCases) { value in
                                Text(value.rawValue).lineLimit(1).truncationMode(.tail).tag(value)
                            }
                        }
                        .pickerStyle(.menu).disabled(settings.cellSize < 6)
                    }
                    HStack {
                        IconLabel("Cell Size", "magnifyingglass")
                        Spacer()
                        Text("\(settings.cellSize)").foregroundColor(.secondary)
                    }.padding(.bottom, 8)
                    Slider(
                        value: Binding(get: { Double(settings.cellSize) }, set: { settings.cellSize = Int($0) }),
                                       in: Double(cellGridView.minimumCellSize(cellPadding: settings.cellPadding))...Double(cellGridView.maximumCellSize), step: 1)
                        .padding(.top, -8).padding(.bottom, -2)
                        .onChange(of: settings.cellSize) { newValue in settings.cellSize = newValue }
                    HStack {
                        IconLabel("Cell Padding", "magnifyingglass")
                        Spacer()
                        Picker("", selection: $settings.cellPadding) {
                            ForEach(cellGridView.minimumCellPadding...cellGridView.maximumCellPadding, id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }.pickerStyle(.menu)
                    }.padding(.bottom, 8)
                }
                VStack {
                    // HStack {
                    //     Image(systemName: "play.circle").frame(width: iconWidth, alignment: .leading)
                    //     Text("Automation").alignmentGuide(.leading) { d in d[.leading] }
                    //     Spacer()
                    //     Toggle("", isOn: $settings.automationEnabled).labelsHidden()
                    // }
                    HStack {
                        IconLabel("Automation Speed", "sparkles")
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
                        IconLabel("Active", "COLOR")
                        Spacer()
                    }
                    ColorPicker("", selection: $settings.activeColorInternal)
                        .onChange(of: settings.activeColorInternal) { newValue in
                           settings.activeColorInternal = newValue
                        }
                }
                HStack {
                    HStack {
                        IconLabel("Inactive", "COLOR")
                        Spacer()
                    }
                    ColorPicker("", selection: $settings.inactiveColorInternal)
                        .onChange(of: settings.inactiveColorInternal) { value in
                           settings.inactiveColorInternal = value
                        }
                }
                HStack {
                    IconLabel("Inactive Random", "number")
                    Spacer()
                    Toggle("", isOn: $settings.inactiveColorRandom).labelsHidden()
                        .onChange(of: settings.inactiveColorRandom) { value in
                            if (!value) {
                                settings.inactiveColorRandomDynamic = false
                            }
                        }
                }
                HStack {
                    IconLabel("Inactive Dynamic", "circle.grid.cross")
                    Spacer()
                    Toggle("", isOn: $settings.inactiveColorRandomDynamic).labelsHidden()
                }.disabled(!settings.inactiveColorRandom)
                HStack {
                    IconLabel("Inactive Color Mode", "paintpalette")
                    Picker("", selection: $settings.inactiveColorRandomColorMode) {
                        ForEach(ColourMode.allCases) { mode in
                            Text(mode.rawValue)
                                .lineLimit(1)
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
                        IconLabel("Background", "COLOR")
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

internal struct IconLabel: View {
    private var _text: String
    private var _icon: String
    private var _iconWidth: CGFloat = 32.0
    internal init(_ text: String, _ icon: String, iconWidth: CGFloat = 32.0) {
        self._text = text
        self._icon = icon
        self._iconWidth = iconWidth
    }
    internal var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if (self._icon == "COLOR") {
                ColorCircleIcon().frame(width: self._iconWidth, alignment: .leading)
            }
            else {
                Image(systemName: self._icon).frame(width: self._iconWidth, alignment: .leading)
            }
            Text(self._text)
                .alignmentGuide(.leading) { d in d[.leading] }
                .fixedSize()
                .layoutPriority(1)
            Spacer()
        }
    }
}
