import SwiftUI
import Utils
import CellGridView

struct ContentView: View
{
    @EnvironmentObject var cellGridView: LifeCellGridView
    @EnvironmentObject var settings: Settings

    @StateObject var orientation = OrientationObserver()

    // This ignoreSafeArea is settable (e.g. in SettingsView); we currently always ignore the safe area;
    // have not been able to get the geometry working in general when NOT ignoring the safe area;
    // the image gets incorrectly shifted (up) on orientation change et cetera; todo someday.
    //
    @State private var ignoreSafeArea: Bool = true
    @State private var viewRectangle: CGRect = CGRect.zero
    @State private var image: CGImage? = nil
    @State private var imageAngle: Angle = Angle.zero
    @State private var showSettingsView = false
    @State private var showControlBar = false

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    if let image = self.image {
                        Image(decorative: image, scale: self.cellGridView.viewScale)
                            .background(GeometryReader { geo in Color.clear
                                .onAppear {
                                    let parentOrigin: CGPoint = geo.frame(in: .named("zstack")).origin
                                    self.viewRectangle = CGRect(origin: self.orientation.landscape
                                                                        ? CGPoint(x: parentOrigin.y, y: parentOrigin.x)
                                                                        : parentOrigin,
                                                                size: CGSize(width: self.cellGridView.viewWidth,
                                                                             height: self.cellGridView.viewHeight))
                                }
                            })
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .rotationEffect(self.imageAngle)
                            .onSmartGesture(
                                dragThreshold: self.settings.dragThreshold,
                                swipeThreshold: self.settings.swipeThreshold,
                                normalizePoint: self.normalizePoint,
                                orientation: self.orientation,
                                onDrag:      { value in self.cellGridView.onDrag(value) },
                                onDragEnd:   { value in self.cellGridView.onDragEnd(value) },
                                onTap:       { value in self.cellGridView.onTap(value) },
                                onDoubleTap: { self.toggleShowControls() },
                                onLongTap:   { _ in self.toggleShowControls() },
                                onZoom:      { value in self.cellGridView.onZoom(value) },
                                onZoomEnd:   { value in self.cellGridView.onZoomEnd(value) },
                                onSwipeLeft: { /* self.showSettings() */ },
                            )
                            NavigationLink(
                                destination: SettingsView().onDisappear {
                                    self.onChangeSettings()
                                },
                                isActive: $showSettingsView,
                                label: { EmptyView() }
                            )
                    }
                }
                .onAppear {
                    if (!self.cellGridView.initialized) {
                        let screen: Screen = Screen(size: geometry.size, scale: UIScreen.main.scale)
                        let landscape = self.orientation.landscape
                        self.cellGridView.initialize(screen: screen,
                                                     viewWidth: landscape ? screen.height : screen.width,
                                                     viewHeight: landscape ? screen.width : screen.height,
                                                     viewBackground: self.settings.viewBackground,
                                                     viewTransparency: self.settings.viewTransparency,
                                                     viewScaling: self.settings.viewScaling,
                                                     cellSize: self.settings.cellSize,
                                                     cellPadding: self.settings.cellPadding,
                                                     cellSizeFit: self.settings.cellSizeFit,
                                                     cellShape: self.settings.cellShape,
                                                     cellColor: self.settings.inactiveColor,
                                                     gridColumns: self.settings.gridColumns,
                                                     gridRows: self.settings.gridRows,
                                                     centerCells: self.settings.centerCells,
                                                     restrictShift: self.settings.restrictShift,
                                                     unscaledZoom: self.settings.unscaledZoom,
                                                     cellAntialiasFade: self.settings.cellAntialiasFade,
                                                     cellRoundedRadius: self.settings.cellRoundedRadius,
                                                     onChangeImage: self.updateImage,
                                                     onChangeCellSize: self.onChangeCellSize)
                        self.rotateImage()
                        if (self.cellGridView.automationMode) {
                            self.cellGridView.automationStart()
                        }
                    }
                    else {
                        //
                        // TODO
                        // Still need to clean up this initialization/re-initializion stuff and on onChangeSettings too.
                        //
                        let screen: Screen = Screen(size: geometry.size, scale: UIScreen.main.scale)
                        if ((screen.width != self.cellGridView.screen.width) ||
                            (screen.height != self.cellGridView.screen.height)) {
                            let landscape = self.orientation.landscape
                            self.cellGridView.configure(screen: screen,
                                                        viewWidth: landscape ? screen.height : screen.width,
                                                        viewHeight: landscape ? screen.width : screen.height,
                                                        viewBackground: self.settings.viewBackground,
                                                        viewTransparency: self.settings.viewTransparency,
                                                        viewScaling: self.settings.viewScaling,
                                                        cellSize: self.settings.cellSize,
                                                        cellPadding: self.settings.cellPadding,
                                                        cellShape: self.settings.cellShape,
                                                        restrictShift: self.settings.restrictShift,
                                                        unscaledZoom: self.settings.unscaledZoom,
                                                        cellAntialiasFade: self.settings.cellAntialiasFade,
                                                        cellRoundedRadius: self.settings.cellRoundedRadius,
                                                        adjustShiftOnResizeCells: true,
                                                        refreshCells: true)
                            self.updateImage()
                        }
                    }
                }
                .navigationTitle("Home")
                .navigationBarHidden(true)
                .background(self.cellGridView.viewBackground.color) // Color.yellow
                .statusBar(hidden: true)
                .coordinateSpace(name: "zstack")
                .overlay(
                    Group {
                        if (self.showControlBar) {
                            ControlBar(
                                selectMode: { self.cellGridView.selectMode },
                                selectModeToggle: self.cellGridView.selectModeToggle,
                                automationMode: { self.cellGridView.automationMode },
                                automationStep: self.cellGridView.automationStep,
                                automationModeToggle: self.cellGridView.automationModeToggle,
                                showSettings: self.showSettings,
                                erase: self.cellGridView.erase
                            )
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 24)
                            .zIndex(2)
                        }
                    },
                    alignment: .bottom
                )
            }
            //
            // TODO: Almost working without safe area; margins
            // off a bit; would be nice if it did as an option.
            //
            .conditionalModifier(self.ignoreSafeArea) { view in
                view.ignoresSafeArea()
            }
        }
        .onAppear {
            self.orientation.register(self.onChangeOrientation)
        }
        .onDisappear {
            self.orientation.deregister()
        }
        .navigationViewStyle(.stack)
    }

    private func normalizePoint(_ location: CGPoint) -> CGPoint {
        return self.orientation.normalizePoint(screenPoint: location, view: self.viewRectangle)
    }

    private func rotateImage() {
        self.imageAngle = self.orientation.rotationAngle()
    }

    private func updateImage() {
        self.image = self.cellGridView.image
    }

    private func onChangeCellSize(cellSize: Int) {
        self.settings.cellSize = cellSize
    }

    private func onChangeOrientation(_ current: UIDeviceOrientation, _ previous: UIDeviceOrientation) {
        self.rotateImage()
    }

    private func onChangeSettings() {
        let configuration: CellGridView.Configuration =
            CellGridView.Configuration(self.cellGridView)
                .with(viewBackground: self.settings.viewBackground)
                .with(viewTransparency: self.settings.viewTransparency)
                .with(viewScaling: self.settings.viewScaling)
                .with(cellSize: self.settings.cellSize)
                .with(cellPadding: self.settings.cellPadding)
        self.cellGridView.configure(viewWidth: self.cellGridView.viewWidth,
                                    viewHeight: self.cellGridView.viewHeight,
                                    viewBackground: self.settings.viewBackground,
                                    viewTransparency: self.settings.viewTransparency,
                                    viewScaling: self.settings.viewScaling,
                                    cellSize: self.settings.cellSize,
                                    cellPadding: self.settings.cellPadding,
                                    cellShape: self.settings.cellShape,
                                    gridColumns: 10, // xyzzy/todo/debug
                                    gridRows: 20, // xyzzy/todo/debug
                                    restrictShift: self.settings.restrictShift,
                                    unscaledZoom: self.settings.unscaledZoom,
                                    cellAntialiasFade: self.settings.cellAntialiasFade,
                                    cellRoundedRadius: self.settings.cellRoundedRadius,
                                    automationInterval: self.settings.automationInterval,
                                    adjustShiftOnResizeCells: true,
                                    refreshCells: true)
        // TODO
        self.cellGridView.activeColor = self.settings.activeColor
        self.cellGridView.noteCellActiveColorChanged()
        self.cellGridView.inactiveColor = self.settings.inactiveColor
        self.cellGridView.noteCellInactiveColorChanged()
        // self.cellGridView.automationInterval = self.settings.automationInterval
        self.cellGridView.inactiveColorRandom = self.settings.inactiveColorRandom
        self.cellGridView.noteCellInactiveColorRandomChanged()
        self.cellGridView.inactiveColorRandomPalette = self.settings.inactiveColorRandomPalette
        self.cellGridView.noteCellInactiveColorRandomPaletteChanged()
        self.cellGridView.inactiveColorRandomDynamic = self.settings.inactiveColorRandomDynamic
        self.cellGridView.noteCellInactiveColorRandomDynamicChanged()
        self.updateImage()
    }

    private func showSettings() {
        self.showSettingsView = true
    }

    private func toggleShowControls() {
        withAnimation {
            self.showControlBar.toggle()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LifeCellGridView())
            .environmentObject(Settings())
    }
}
