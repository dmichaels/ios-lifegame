// Example mostly from ChatGPT relevant to simplifying ios-lifegame 2027-07-31 ...

import SwiftUI

struct ContentView: View {
    @State private var imageSize: CGSize = .zero
    @State private var image: CGImage? = nil
    @State private var toggleSize = false
    @State private var zstackSize: CGSize = .zero

    var body: some View {
        GeometryReader { geometryMain in
            ZStack {
                Color.black.ignoresSafeArea()
                if let image: CGImage = image {
                    Image(decorative: image, scale: 1.0)
                        .resizable()
                        .frame(width: CGFloat(image.width), height: CGFloat(image.height))
                        .background(GeometryReader { geometryImage in
                            Color.clear .onAppear { self.imageSize = geometryImage.size }
                        })
                        .position(x: geometryMain.size.width / 2, y: geometryMain.size.height / 2)
                        .onSmartGesture(
                            normalizePoint: self.normalizePoint,
                            ignorePoint: self.ignorePoint,
                            onTap: { imagePoint in
                                if (self.inrangePoint(imagePoint)) {
                                    print("TAP: \(imagePoint) image-size: \(self.imageSize.width)x\(self.imageSize.height)")
                                    toggleSize.toggle()
                                    self.image = self.createImage(maxSize: geometryMain.size, large: toggleSize)
                                    self.imageSize = CGSize(width: self.image!.width, height: self.image!.height)
                                }
                                else {
                                    print("TAP-NO: \(imagePoint) image-size: \(self.imageSize.width)x\(self.imageSize.height)")
                                }
                            },
                            onDoubleTap: { imagePoint in
                                print("DOUBLE-TAP> \(imagePoint)")
                            },
                            onLongTap: { imagePoint in
                                print("LONG-TAP> \(imagePoint)")
                            },
                            onDrag: { imagePoint in
                                print("DRAG> \(imagePoint)")
                            },
                            onDragStrict: true
                        )
                        /*
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onEnded { value in
                                    let imagePoint = self.normalizePoint(value.location)
                                    if (self.inrangePoint(imagePoint)) {
                                        print("TAP: \(value.location) -> image-point: \(imagePoint) image-size: \(self.imageSize.width)x\(self.imageSize.height)")
                                        toggleSize.toggle()
                                        self.image = self.createImage(maxSize: geometryMain.size, large: toggleSize)
                                        self.imageSize = CGSize(width: self.image!.width, height: self.image!.height)
                                    }
                                    else {
                                        print("TAP-NO: \(value.location) -> image-point: \(imagePoint) image-size: \(self.imageSize.width)x\(self.imageSize.height)")
                                    }
                                }
                        )
                        */
                }
            }
            .onAppear {
                self.image = self.createImage(maxSize: geometryMain.size, large: toggleSize)
                self.zstackSize = geometryMain.size
            }
        }
    }

    private func normalizePoint(_ zstackPoint: CGPoint) -> CGPoint {
        let imageOrigin: CGPoint = CGPoint(
            x: (self.zstackSize.width - self.imageSize.width) / 2,
            y: (self.zstackSize.height - self.imageSize.height) / 2
        )
        return CGPoint(x: zstackPoint.x - imageOrigin.x, y: zstackPoint.y - imageOrigin.y)
    }

    private func inrangePoint(_ point: CGPoint) -> Bool {
        return (point.x >= 0) && (point.y >= 0) && (point.x < self.imageSize.width) && (point.y < self.imageSize.height)
    }

    private func ignorePoint(_ normalizedPoint: CGPoint) -> Bool {
        return !self.inrangePoint(normalizedPoint)
    }

    private func createImage(maxSize: CGSize, large: Bool = false) -> CGImage {
        let width = large ? min(Int(maxSize.width), 300) : min(Int(maxSize.width), 150)
        let height = large ? min(Int(maxSize.height), 200) : min(Int(maxSize.height), 100)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.setFillColor(UIColor.red.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        return context.makeImage()!
    }
}
