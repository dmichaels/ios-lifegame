import SwiftUI
import Utils
import CellGridView

struct ContentView: View
{
    @EnvironmentObject var cellGridView: LifeCellGridView
    @EnvironmentObject var settings: Settings
    @StateObject var orientation: OrientationObserver = OrientationObserver()
    //
    // This ignoreSafeArea is settable (e.g. in SettingsView); we currently always ignore the safe area;
    // have not been able to get the geometry working in general when NOT ignoring the safe area;
    // the image gets incorrectly shifted (up) on orientation change et cetera; todo someday.
    //
    @State private var ignoreSafeArea: Bool = true
    @State private var hideStatusBar: Bool = Settings.Defaults.hideStatusBar
    @State private var viewRectangle: CGRect = CGRect.zero
    @State private var image: CGImage? = nil
    @State private var imageAngle: Angle = Angle.zero
    @State private var showSettingsView: Bool = false
    @State private var showControlBar: Bool = false
    @State private var screenBackground: Colour? = nil
    @State private var feedback: Feedback = Feedback()

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
                                dragThreshold: self.cellGridView.dragThreshold,
                                swipeThreshold: self.cellGridView.swipeThreshold,
                                normalizePoint: self.normalizePoint,
                                orientation: self.orientation,
                                onDrag:      { value in self.cellGridView.onDrag(value) },
                                onDragEnd:   { value in self.cellGridView.onDragEnd(value) },
                                onTap:       { value in self.cellGridView.onTap(value) ; feedback.trigger() },
                                onDoubleTap: { self.toggleShowControls() },
                                onLongTap:   { _ in self.toggleShowControls() },
                                onZoom:      { value in self.cellGridView.onZoom(value) },
                                onZoomEnd:   { value in self.cellGridView.onZoomEnd(value) },
                                onSwipeLeft: { /* self.showSettings() */ },
                            )
                            NavigationLink(
                                destination: SettingsView()
                                    .onDisappear {
                                        self.updateSettings()
                                    },
                                isActive: $showSettingsView,
                                label: { EmptyView() }
                            )
                    }
                }
                .onAppear {
                    if (!self.cellGridView.initialized) {
                        //
                        // See comment at top WRT setting our local automationMode state variable here.
                        //
                        // self.automationMode = self.settings.automationMode
                        // self.selectRandomMode = self.settings.selectRandomMode
                        let screen: Screen = Screen(size: geometry.size, scale: UIScreen.main.scale)
                        let landscape = self.orientation.landscape
                        self.cellGridView.initialize(self.settings,
                                                     screen: screen,
                                                     viewWidth: landscape ? screen.height : screen.width,
                                                     viewHeight: landscape ? screen.width : screen.height,
                                                     updateImage: self.updateImage)
                        self.rotateImage()
                        self.updateImage()
                        // if (self.settings.automationMode) { self.automationStart() }
                        // if (self.settings.selectRandomMode) { self.selectRandomStart() }
                        // self.cellGridView.selectMode = self.settings.selectMode
                        self.feedback.soundsEnabled = settings.soundsEnabled
                        self.feedback.hapticsEnabled = settings.hapticsEnabled
                        self.hideStatusBar = settings.hideStatusBar
                    }
                    else {
                        let screen: Screen = Screen(size: geometry.size, scale: UIScreen.main.scale)
                        if ((screen.width != self.cellGridView.screen.width) ||
                            (screen.height != self.cellGridView.screen.height)) {
                        }
                    }
                    /*
                     * ACTUALLY ...
                     * Forget why we even needed this; maybe for turning on/off ignoreSafeArea ...
                     * which does not currently (nor ever we think) work ....
                     *
                    else {
                        //
                        // TODO
                        // Still need to clean up this initialization/re-initializion stuff and on updateSettings too.
                        //
                        let screen: Screen = Screen(size: geometry.size, scale: UIScreen.main.scale)
                        if ((screen.width != self.cellGridView.screen.width) ||
                            (screen.height != self.cellGridView.screen.height)) {
                            let landscape = self.orientation.landscape
                            self.cellGridView.configure(self.cellGridView.config,
                                                        viewWidth: landscape ? screen.height : screen.width,
                                                        viewHeight: landscape ? screen.width : screen.height)
                        }
                    } ... */
                }
                .navigationTitle("Home")
                .navigationBarHidden(true)
                .background(self.screenBackground?.color ?? self.cellGridView.viewBackground.color)
                .statusBar(hidden: self.hideStatusBar)
                .coordinateSpace(name: "zstack")
                .overlay(
                    Group {
                        if (self.showControlBar) {
                            ControlBar(
                                selectMode: $settings.selectMode,
                                selectModeToggle: self.selectModeToggle,
                                automationMode: $settings.automationMode,
                                automationModeToggle: self.automationModeToggle,
                                automationStep: self.cellGridView.automationStep,
                                selectRandomMode: $settings.selectRandomMode,
                                selectRandomModeToggle: self.selectRandomModeToggle,
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
            self.orientation.register(self.updateOrientation)
        }
        .onDisappear {
            self.orientation.deregister()
        }
        .navigationViewStyle(.stack)
    }

    private func showSettings() {
        self.automationPause()
        self.selectRandomPause()
        self.settings.fromConfig(self.cellGridView)
        self.showSettingsView = true
    }

    private func updateSettings() {
        if (self.settings.gameMode == GameMode.lifehash) {
            self.automationStop()
            self.cellGridView.lifehash(self.settings)
            return
        }
        self.cellGridView.configure(self.settings)
        self.updateImage()
        self.feedback.soundsEnabled = settings.soundsEnabled
        self.feedback.hapticsEnabled = settings.hapticsEnabled
        self.hideStatusBar = settings.hideStatusBar
        self.automationResume()
        self.selectRandomResume()
        settings.automationMode ? self.automationStart() : self.automationStop()
        settings.selectRandomMode ? self.selectRandomStart() : self.selectRandomStop()
    }

    private func toggleShowControls() {
        withAnimation { self.showControlBar.toggle() }
    }

    private func updateImage() {
        self.image = self.cellGridView.image
    }

    private func rotateImage() {
        self.imageAngle = self.orientation.rotationAngle()
    }

    private func updateOrientation(_ current: UIDeviceOrientation, _ previous: UIDeviceOrientation) {
        self.rotateImage()
    }

    private func normalizePoint(_ location: CGPoint) -> CGPoint {
        return self.orientation.normalizePoint(screenPoint: location, view: self.viewRectangle)
    }

    private func automationModeToggle() {
        self.cellGridView.automationModeToggle()
        self.settings.automationMode = self.cellGridView.automationMode
    }

    private func automationStart() {
        self.cellGridView.automationStart()
        self.settings.automationMode = self.cellGridView.automationMode
    }

    private func automationStop() {
        self.cellGridView.automationStop()
        self.settings.automationMode = self.cellGridView.automationMode
    }

    private func automationPause() {
        self.cellGridView.automationPause()
    }

    private func automationResume() {
        self.cellGridView.automationResume()
    }

    private var selectMode: Bool {
        get { self.cellGridView.selectMode }
        set { self.cellGridView.selectMode = newValue }
    }

    private func selectModeToggle() {
        self.cellGridView.selectModeToggle()
    }

    private func selectRandomModeToggle() {
        self.cellGridView.selectRandomModeToggle()
        self.settings.selectRandomMode = self.cellGridView.selectRandomMode
    }

    private func selectRandomStart() {
        self.cellGridView.selectRandomStart()
        self.settings.selectRandomMode = self.cellGridView.selectRandomMode
    }

    private func selectRandomStop() {
        self.cellGridView.selectRandomStop()
        self.settings.selectRandomMode = self.cellGridView.selectRandomMode
    }

    private func selectRandomPause() {
        self.cellGridView.selectRandomPause()
    }

    private func selectRandomResume() {
        self.cellGridView.selectRandomResume()
    }
}

struct ContentView_Previews: PreviewProvider {
    init() { LatixCell.circleCellLocationsPreload() }
    static var previews: some View {
        ContentView()
            .environmentObject(LifeCellGridView())
            .environmentObject(Settings())
    }
}
