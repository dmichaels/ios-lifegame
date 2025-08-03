
// Example mostly from ChatGPT relevant to simplifying ios-lifegame 2027-07-31 ...

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var settings: Settings
    @State private var image: CGImage? = nil
    @State private var imageSize: CGSize = .zero
    @State private var imagePosition: CGPoint = .zero
    @State private var imageAngle: Angle = .zero
    @State private var imageSizeLarge = false
    @State private var containerSize: CGSize = .zero
    @State private var containerBackground: Color? = Color.yellow
    @State private var showSettingsView: Bool = false
    @State private var hideStatusBar: Bool = false
    @State private var ignoreSafeArea: Bool = false
    @StateObject private var orientation: OrientationObserver = OrientationObserver()

    var body: some View {
        NavigationView {
            ZStack {
                (containerBackground ?? Color.green) // important trickery here
                GeometryReader { containerGeometry in
                    ZStack {
                        if let image: CGImage = image {
                            Image(decorative: image, scale: 1.0)
                                .resizable()
                                .frame(width: CGFloat(image.width), height: CGFloat(image.height))
                                .position(x: containerGeometry.size.width / 2, y: containerGeometry.size.height / 2)
                                .rotationEffect(self.imageAngle)
                                .onSmartGesture(
                                    normalizePoint: self.normalizePoint, ignorePoint: self.ignorePoint,
                                    onTap: { imagePoint in
                                        print("TAP> \(imagePoint) is: \(imageSize.width)x\(imageSize.height) zg: \(containerGeometry.size) zs: \(containerSize) ssv: \(self.showSettingsView)")
                                        self.changeImage()
                                    },
                                    onSwipeLeft: { self.showSettingsView = true }
                                )
                        }
                        NavigationLink(destination: SettingsView(), isActive: $showSettingsView) { EmptyView() }.hidden()
                    }
                    .onAppear {
                        self.containerSize = containerGeometry.size
                        self.imagePosition = CGPoint(x: (self.containerSize.width - self.imageSize.width) / 2,
                                                     y: (self.containerSize.height - self.imageSize.height) / 2)
                        self.image = self.createImage(maxSize: self.containerSize, large: self.imageSizeLarge)
                        print("ZSTACK-ONAPPEAR> zs: \(self.containerSize.width)x\(self.containerSize.height) is: \(imageSize.width)x\(imageSize.height)")
                        self.updateSettings()
                    }
                }
            }
            .onSmartGesture( onTap: { imagePoint in print("ZSTACK-TAP> \(imagePoint) zs: \(self.containerSize.width)x\(self.containerSize.height) is: \(imageSize.width)x\(imageSize.height)") })
            .safeArea(ignore: ignoreSafeArea)
            .statusBar(hidden: hideStatusBar)
            .toolBar(hidden: ignoreSafeArea, showSettingsView: $showSettingsView)
        }
        .onAppear { self.orientation.register(self.updateOrientation) }
        .onDisappear { self.orientation.deregister() }
    }

    private func updateSettings() {
        if (self.showSettingsView) {
            //
            // Note that showSettingsView gets set back to false automatically
            // by SwiftUI after the SettingView show/return cycle completes.
            //
            hideStatusBar = self.settings.hideStatusBar
            ignoreSafeArea = self.settings.ignoreSafeArea
        }
    }

    private func normalizePoint(_ containerPoint: CGPoint) -> CGPoint {
        let imageOrigin: CGPoint = CGPoint(
            x: (self.containerSize.width - self.imageSize.width) / 2,
            y: (self.containerSize.height - self.imageSize.height) / 2
        )
        return CGPoint(x: containerPoint.x - imageOrigin.x, y: containerPoint.y - imageOrigin.y)
    }

    private func ignorePoint(_ point: CGPoint) -> Bool {
        return (point.x < 0) || (point.y < 0) || (point.x >= self.imageSize.width) || (point.y >= self.imageSize.height)
    }

    private func rotateImage() {
        self.imageAngle = self.orientation.rotationAngle()
    }

    private func updateOrientation(_ current: UIDeviceOrientation, _ previous: UIDeviceOrientation) {
        self.rotateImage()
    }

    private func changeImage() {
        self.imageSizeLarge.toggle()
        self.image = self.createImage(maxSize: self.containerSize, large: self.imageSizeLarge)
        self.imageSize = CGSize(width: self.image!.width, height: self.image!.height)
    }

    private func createImage(maxSize: CGSize, large: Bool = false) -> CGImage? {
        let width = !large ? 200 : Int(maxSize.width)
        let height = !large ? 300 : Int(maxSize.height)
        let context = CGContext(
            data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)
        context.setFillColor(UIColor.blue.cgColor)
        context.fill(CGRect(x: width / 2 - 10, y: 50, width: 20, height: 30))
        let image: CGImage = context.makeImage()!
        self.imageSize = CGSize(width: image.width, height: image.height)
        print("CREATE-IMAGE> large: \(large) size: \(self.imageSize.width)x\(self.imageSize.height)")
        return image
    }
}

extension View {
    @ViewBuilder
    public func safeArea(ignore: Bool) -> some View {
        if (ignore) { self.ignoresSafeArea() } else { self }
    }
}

class Settings: ObservableObject {
    @Published var ignoreSafeArea: Bool = false
    @Published var hideStatusBar: Bool = false
}

struct SettingsView: View {
    @EnvironmentObject private var settings: Settings
    var body: some View {
        Form {
            Text("Settings ...")
            Toggle("Ignore Safe Area", isOn: $settings.ignoreSafeArea)
            Toggle("Hide Status Bar", isOn: $settings.hideStatusBar)
        }
        .navigationTitle("Settings")
    }
}

extension View {
    @ViewBuilder
    func toolBar(hidden: Bool, showSettingsView: Binding<Bool>) -> some View {
        if (hidden) {
            self
        } else {
            self.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Home").font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettingsView.wrappedValue = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}
