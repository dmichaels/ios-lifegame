import SwiftUI
import CellGridView
import Utils

struct SettingsView: View
{
    @EnvironmentObject private var cellGridView: LifeCellGridView
    @EnvironmentObject private var settings: Settings
    @State private var cellSizeDisplay: Int? = nil
    @State private var selectMode: Int = 0

    var body: some View {
        Form {
            SettingsSection {
                HStack {
                    IconLabel("Cell Shape", "puzzlepiece.fill")
                    Picker("", selection: $settings.cellShape) {
                        ForEach(CellShape.allCases) { value in
                            Text(value.rawValue).lineLimit(1).truncationMode(.tail).tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: settings.cellShape) { value in
                        settings.viewScaling = !cellGridView.cellShapeRequiresNoScaling(value)
                    }
                }

                VStack {
                    HStack {
                        IconLabel("Cell Size", "magnifyingglass")
                        Text("\(cellSizeDisplay ?? settings.cellSize)").foregroundColor(.secondary)
                    }.padding(.bottom, 4)
                    Slider(
                        value: Binding(get: { Double(settings.cellSize) }, set: { settings.cellSize = Int($0.rounded()) }),
                                       in: cellSizeRange(), step: 1)
                        .padding(.top, -8).padding(.bottom, -2)
                        .onChange(of: settings.cellSize) { value in
                            cellSizeDisplay = (
                                settings.fit != CellGridView.Fit.disabled
                                ? cellGridView.preferredSize(settings.cellSize, fit: settings.fit).cellSize
                                : nil
                            )
                            if (settings.fit != CellGridView.Fit.disabled) {
                                let preferred = cellGridView.preferredSize(settings.cellSize, fit: settings.fit)
                                cellGridView.preferredSize(settings.cellSize, fit: settings.fit).cellSize
                            }
                        }
                }

                HStack {
                    IconLabel("Cell Padding", "squareshape.dotted.squareshape")
                    Picker("", selection: $settings.cellPadding) {
                        ForEach(cellGridView.minimumCellPadding...cellGridView.maximumCellPadding, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: settings.cellPadding) { value in
                        let minimumCellSize: Int = cellGridView.minimumCellSize(cellPadding: settings.cellPadding,
                                                                                cellShape: settings.cellShape)
                        if (settings.cellSize < minimumCellSize) {
                            settings.cellSize = minimumCellSize
                        }
                    }
                }

                HStack {
                    IconLabel("Cell Shading", "square.filled.on.square")
                    Toggle("", isOn: $settings.cellShading).labelsHidden()
                }
            }

            SettingsSection("GAME: " + (settings.gameMode == GameMode.life ? "CONWAY'S LIFE" : "CIRCLES")) {
                HStack {
                    IconLabel("Game Mode", "gamecontroller")
                    Picker("", selection: $settings.gameMode) {
                        ForEach(GameMode.allCases) { value in
                            Text(value.rawValue).lineLimit(1).truncationMode(.tail).tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                }

                HStack {
                    IconLabel("InactiveFade Variant", "eye.fill")
                    Toggle("", isOn: $settings.variantInactiveFade)
                }
                .hide(settings.gameMode != GameMode.life)

                HStack {
                    IconLabel("HighLife Variant", "lifepreserver")
                    Toggle("", isOn: $settings.variantHighLife)
                }
                .hide(settings.gameMode != GameMode.life)

                HStack {
                    IconLabel("OverPopulate Variant", "gauge.with.dots.needle.bottom.100percent")
                    Toggle("", isOn: $settings.variantOverPopulate)
                }
                .hide(settings.gameMode != GameMode.life)

                HStack {
                    IconLabel("Select Mode", "rectangle.and.pencil.and.ellipsis")
                    Picker("", selection: $selectMode) {
                        ForEach(SelectModeOptions, id: \.value) { option in Text(option.label) }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectMode) { value in
                        switch value {
                        case 1:  settings.selectModeFat = true
                                 settings.selectModeExtraFat = false
                        case 2:  settings.selectModeFat = false
                                 settings.selectModeExtraFat = true
                        default: settings.selectModeFat = false
                                 settings.selectModeExtraFat = false
                        }
                    }
                    .onAppear {
                        if settings.selectModeExtraFat { self.selectMode = 2 }
                        else if settings.selectModeFat { self.selectMode = 1 }
                        else { self.selectMode = 0 }
                    }
                }
                .hide(settings.gameMode != GameMode.life)

                HStack {
                    IconLabel("Speed", "waveform.path")
                    Picker("", selection: $settings.automationInterval) {
                        ForEach(AutomationIntervalOptions, id: \.value) { option in
                            Text(option.label)
                                .tag(option.value)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            SettingsSection("COLORS") {
                HStack {
                    IconLabel("Active", "COLOR")
                    ColorPicker("", selection: $settings.activeColorInternal)
                        .onChange(of: settings.activeColorInternal) { newValue in
                           settings.activeColorInternal = newValue
                        }
                }
                .hide(settings.gameMode != GameMode.life)

                HStack {
                    IconLabel("Inactive", "COLOR")
                    ColorPicker("", selection: $settings.inactiveColorInternal)
                        .onChange(of: settings.inactiveColorInternal) { value in
                           settings.inactiveColorInternal = value
                        }
                }
                .hide(settings.gameMode != GameMode.life)

                HStack {
                    IconLabel("Inactive Random", "circle.grid.cross.right.filled")
                    Toggle("", isOn: $settings.inactiveColorRandom).labelsHidden()
                        .onChange(of: settings.inactiveColorRandom) { value in
                            if (!value) {
                                settings.inactiveColorRandomDynamic = false
                            }
                        }
                }
                .hide(settings.gameMode != GameMode.life)

                HStack {
                    IconLabel("Inactive Dynamic", "sparkles")
                    Toggle("", isOn: $settings.inactiveColorRandomDynamic).labelsHidden()
                }
                .disabled(!settings.inactiveColorRandom)
                .hide(settings.gameMode != GameMode.life)

                HStack {
                    IconLabel("Inactive Palette", "paintpalette")
                    Picker("", selection: $settings.inactiveColorRandomPalette) {
                        ForEach(ColourPalette.allCases) { mode in
                            Text(mode.rawValue).lineLimit(1).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: settings.inactiveColorRandomPalette) { newValue in
                        settings.inactiveColorRandomPalette = newValue
                    }
                }
                .disabled(!settings.inactiveColorRandom)
                .hide(settings.gameMode != GameMode.life)

                HStack {
                    IconLabel("Background", "COLOR")
                    ColorPicker("", selection: $settings.viewBackgroundInternal)
                        .onChange(of: settings.viewBackgroundInternal) { newValue in
                           settings.viewBackgroundInternal = newValue
                        }
                }
            }

            SettingsSection("GRID") {
                HStack {
                    IconLabel("Grid Fixed", "square.grid.3x3.square")
                    Toggle("", isOn: Binding<Bool>(
                        get: { settings.fit == CellGridView.Fit.fixed },
                        set: { value in
                            if (value) {
                                settings.fit = CellGridView.Fit.fixed
                            }
                            else {
                                settings.fit = CellGridView.Fit.disabled
                                settings.gridColumns = Settings.Defaults.gridColumns
                                settings.gridRows = Settings.Defaults.gridRows
                            }
                        }
                    ))
                }

                HStack {
                    IconLabel("Grid Center", "align.horizontal.center")
                        .disabled(settings.fit == CellGridView.Fit.fixed)
                    Toggle("", isOn: $settings.center).labelsHidden()
                        .disabled(settings.fit == CellGridView.Fit.fixed)
                }
            }

            SettingsSection("MULTIMEDIA") {
                HStack {
                    IconLabel("Sounds", "speaker.wave.2")
                    Toggle("", isOn: $settings.soundsEnabled)
                }

                HStack {
                    IconLabel("Haptics", "water.waves")
                    Toggle("", isOn: $settings.hapticsEnabled)
                }
            }

            SettingsSection("ADVANCED", icon: "apple.logo") {
                HStack {
                    IconLabel("Pixel Scaling", "scale.3d")
                    Toggle("", isOn: $settings.viewScaling).labelsHidden()
                        .onChange(of: settings.viewScaling) { value in
                            if (!value) {
                                settings.viewScaling = false
                            }
                        }
                        .disabled(cellGridView.cellShapeRequiresNoScaling(settings.cellShape))
                }

                HStack {
                    IconLabel("Restrict Shift", "arrow.up.left.arrow.down.right.square")
                    Toggle("", isOn: $settings.restrictShift).labelsHidden()
                }

                HStack {
                    IconLabel("Unscaled Zoom", "minus.magnifyingglass")
                    Toggle("", isOn: $settings.unscaledZoom)
                }
            }
        }
        .offset(y: -30)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    func cellSizeRange() -> ClosedRange<Double> {
        let min: Double = Double(cellGridView.minimumCellSize(cellPadding: settings.cellPadding,
                                                              cellShape: settings.cellShape))
        return min...Double(cellGridView.maximumCellSize)
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
    ("Wow", 0.02),
    ("Max", 0.0)
]

let SelectModeOptions: [(label: String, value: Int)] = [
    ("Default", 0),
    ("Fat", 1),
    ("Very Fat", 2)
]
