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
                                    self.viewRectangle = CGRect(origin: self.orientation.current.isLandscape
                                                                        ? CGPoint(x: parentOrigin.y, y: parentOrigin.x)
                                                                        : parentOrigin,
                                                                size: CGSize(width: self.cellGridView.viewWidth,
                                                                             height: self.cellGridView.viewHeight))
                                }
                            })
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .rotationEffect(self.imageAngle)
                            .onSmartGesture(
                                dragThreshold: Defaults.dragThreshold,
                                swipeThreshold: Defaults.swipeThreshold,
                                normalizePoint: self.normalizePoint,
                                orientation: self.orientation,
                                onDrag:      { value in self.cellGridView.onDrag(value) },
                                onDragEnd:   { value in self.cellGridView.onDragEnd(value) },
                                onTap:       { value in self.cellGridView.onTap(value) },
                                onDoubleTap: { self.toggleShowControls() },
                                onZoom:      { value in self.cellGridView.onZoom(value) },
                                onZoomEnd:   { value in self.cellGridView.onZoomEnd(value) },
                                onSwipeLeft: { self.showSettings() },
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
                        let landscape = self.orientation.current.isLandscape
                        self.cellGridView.initialize(screen: screen,
                                                     viewWidth: landscape ? screen.height : screen.width,
                                                     viewHeight: landscape ? screen.width : screen.height,
                                                     viewBackground: Defaults.viewBackground,
                                                     viewTransparency: Defaults.viewTransparency,
                                                     viewScaling: Defaults.viewScaling,
                                                     cellSize: Defaults.cellSize,
                                                     cellPadding: Defaults.cellPadding,
                                                     cellSizeFit: Defaults.cellSizeFit,
                                                     cellShape: Defaults.cellShape,
                                                     cellForeground: Defaults.inactiveColor,
                                                     gridColumns: Defaults.gridColumns,
                                                     gridRows: Defaults.gridRows,
                                                     gridCenter: Defaults.gridCenter,
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
                        if ((screen.width != self.cellGridView.screen.width) || (screen.height != self.cellGridView.screen.height)) {
                            let landscape = self.orientation.current.isLandscape
                            self.cellGridView.configure(cellSize: self.settings.cellSize,
                                                        cellPadding: self.cellGridView.cellPadding,
                                                        cellShape: self.settings.cellShape,
                                                        viewWidth: landscape ? screen.height : screen.width,
                                                        viewHeight: landscape ? screen.width : screen.height,
                                                        viewBackground: self.settings.viewBackground,
                                                        viewTransparency: self.cellGridView.viewTransparency,
                                                        viewScaling: self.settings.viewScaling, // self.cellGridView.viewScaling,
                                                        screen: screen,
                                                        adjustShift: true,
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

    private func updateImage() {
        self.image = self.cellGridView.image
    }

    private func onChangeCellSize(cellSize: Int) {
        self.settings.cellSize = cellSize
    }

    private func rotateImage() {
        switch self.orientation.current {
        case .landscapeLeft:
            self.imageAngle = Angle.degrees(-90)
        case .landscapeRight:
            self.imageAngle = Angle.degrees(90)
        case .portraitUpsideDown:
            //
            // All sorts of odd trouble with upside-down mode;
            // going there from portrait yields portrait mode;
            // going there from landscape yield upside-down mode.
            // But still acts weird sometimes (e.g. iPhone SE via
            // Jake and iPad simulator); best to just disable
            // upside-down mode in project deployment-info.
            //
            if (orientation.ipad) {
                self.imageAngle = Angle.degrees(180)
            }
            else if (self.orientation.previous.isLandscape) {
                self.imageAngle = Angle.degrees(90)
            } else {
                self.imageAngle = Angle.degrees(0)
            }
        default:
            self.imageAngle = Angle.degrees(0)
        }
    }

    private func normalizePoint(_ location: CGPoint) -> CGPoint {
        return self.orientation.normalizePoint(screenPoint: location, view: self.viewRectangle)
    }

    private func onChangeOrientation(_ current: UIDeviceOrientation, _ previous: UIDeviceOrientation) {
        self.rotateImage()
    }

    private func onChangeSettings() {
        let configuration: CellGridView.Configuration = CellGridView.Configuration().with(cellSize: 123)
        let cellSizeChanged: Bool = (self.settings.cellSize != self.cellGridView.cellSize)
        self.cellGridView.configure(cellSize: self.settings.cellSize,
                                    cellPadding: self.settings.cellPadding,
                                    cellShape: self.settings.cellShape,
                                    viewWidth: self.cellGridView.viewWidth,
                                    viewHeight: self.cellGridView.viewHeight,
                                    viewBackground: self.settings.viewBackground,
                                    viewTransparency: self.cellGridView.viewTransparency,
                                    viewScaling: self.settings.viewScaling,
                                    adjustShift: true,
                                    refreshCells: true)
        self.cellGridView.activeColor = self.settings.activeColor
        self.cellGridView.inactiveColor = self.settings.inactiveColor
        self.cellGridView.automationInterval = self.settings.automationInterval
        self.cellGridView.inactiveColorRandom = self.settings.inactiveColorRandom
        self.cellGridView.inactiveColorRandomColorMode = self.settings.inactiveColorRandomColorMode
        self.cellGridView.inactiveColorRandomDynamic = self.settings.inactiveColorRandomDynamic
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
