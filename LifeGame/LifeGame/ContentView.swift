import SwiftUI
import Utils
import CellGridView

struct ContentView: View
{
    @EnvironmentObject var cellGridView: LifeCellGridView
    @EnvironmentObject var settings: Settings

    @StateObject var orientation = OrientationObserver()

    // This ignoreSafeArea is settable (e.g. in SettingsView); we currently always ignore the
    // safe area; have not been able to get the geometry working in general when NOT ignoring
    // the safe area; the image gets incorrectly shifted et cetera; TODO at some point.
    //
    @State private var ignoreSafeArea: Bool = true
    @State private var viewRectangle: CGRect = CGRect.zero
    @State private var image: CGImage? = nil
    @State private var imageAngle: Angle = Angle.zero

    @State private var showSettingsView = false
    @State private var showControlsBar = false
    @State private var dragging: Bool = false
    @State private var draggingStart: CGPoint? = nil
    @State private var paintMode = false
    @State private var playMode = false

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    if let image = image {
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
                                // TODO
                                // Triple check that we don't actually need this; artifact of
                                // previous development evidently; seems it never gets called,
                                // except (sometimes) in response to the onAppear setting above.
                                //
                                // .onChange(of: self.parentRelativeImagePosition) { value in
                                //     self.parentRelativeImagePosition = value
                                // }
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
                                                     cellForeground: Defaults.cellForeground,
                                                     gridColumns: Defaults.gridColumns,
                                                     gridRows: Defaults.gridRows,
                                                     gridCenter: Defaults.gridCenter,
                                                     onChangeImage: self.updateImage,
                                                     onChangeCellSize: self.onChangeCellSize)
                        self.rotateImage()
                    }
                    else {
                        let screen: Screen = Screen(size: geometry.size, scale: UIScreen.main.scale)
                        if ((screen.width != self.cellGridView.screen.width) || (screen.height != self.cellGridView.screen.height)) {
                            let landscape = self.orientation.current.isLandscape
                            self.cellGridView.configure(cellSize: settings.cellSize,
                                                        cellPadding: self.cellGridView.cellPadding,
                                                        cellShape: settings.cellShape,
                                                        viewWidth: landscape ? screen.height : screen.width,
                                                        viewHeight: landscape ? screen.width : screen.height,
                                                        viewBackground: settings.viewBackground,
                                                        viewTransparency: self.cellGridView.viewTransparency,
                                                        viewScaling: settings.viewScaling, // self.cellGridView.viewScaling,
                                                        screen: screen,
                                                        adjustShift: true,
                                                        refreshCells: true)
                            self.updateImage()
                        }
                    }
                }
                .navigationTitle("Home")
                .navigationBarHidden(true)
                // .background(self.cellGridView.background.color) // xyzzy
                // .background(Color.pink) // xyzzy
                .background(Color.yellow) // xyzzy
                .statusBar(hidden: true)
                .coordinateSpace(name: "zstack")
                .overlay(
                    Group {
                        if (self.showControlsBar) {
                            ControlsBar(
                                playMode: $playMode,
                                paintMode: $paintMode,
                                onAnyTap: nil,
                                showSettings: self.showSettings,
                                togglePaintMode: self.togglePaintMode,
                                togglePlayMode: self.togglePlayMode
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
            // TODO: Almost working without this; margins
            // off a bit; would be nice if it did as an option.
            //
            .conditionalModifier(ignoreSafeArea) { view in
                view.ignoresSafeArea()
            }
        }
        .onAppear {
            orientation.register(self.onChangeOrientation)
        }
        .onDisappear {
            orientation.deregister()
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
        let cellSizeChanged: Bool = (settings.cellSize != self.cellGridView.cellSize)
        self.cellGridView.configure(cellSize: settings.cellSize,
                                    cellPadding: self.cellGridView.cellPadding,
                                    cellShape: settings.cellShape,
                                    viewWidth: self.cellGridView.viewWidth,
                                    viewHeight: self.cellGridView.viewHeight,
                                    viewBackground: settings.viewBackground,
                                    viewTransparency: self.cellGridView.viewTransparency,
                                    viewScaling: settings.viewScaling,
                                    adjustShift: true,
                                    refreshCells: true)
        self.cellGridView.cellActiveColor = settings.cellActiveColor
        self.cellGridView.automationInterval = settings.automationInterval
        self.updateImage()
    }

    private func showSettings() {
        self.showSettingsView = true
    }

    private func toggleShowControls() {
        withAnimation {
            self.showControlsBar.toggle()
        }
    }

    private func togglePaintMode() {
        paintMode.toggle()
        self.cellGridView.togglePaintMode()
    }

    private func togglePlayMode() {
        playMode.toggle()
        self.cellGridView.togglePlayMode()
    }
}

struct ContentView_Previews: PreviewProvider {
    static let cellGridView: LifeCellGridView = LifeCellGridView()
    static let settings: Settings = Settings()
    static var previews: some View {
        ContentView()
            .environmentObject(cellGridView)
            .environmentObject(settings)
    }
}
