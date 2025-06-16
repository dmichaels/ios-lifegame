
import SwiftUI
import UIKit

struct ControlBar: View {
    @Binding var automationMode: Bool
    @Binding var selectMode: Bool
    var onAnyTap: (() -> Void)?
    var showSettings: (() -> Void)?
    var toggleSelectMode: (() -> Void)?
    var toggleAutomationMode: (() -> Void)?

    var body: some View {
        HStack(spacing: 36) {
            Button(action: {
                toggleAutomationMode?()
                onAnyTap?()
            }) {
                Image(systemName: self.automationMode ? "pause.fill" : "play.fill")
                    .font(.system(size: 24, weight: .bold))
            }
            Button(action: {
                toggleSelectMode?()
                onAnyTap?()
            }) {
                // Image(systemName: self.selectMode ? "hand.draw.fill" : "paintbrush.fill")
                // Image(systemName: self.selectMode ? "arrow.up.and.down.and.arrow.left.and.right" : "paintbrush.fill")
                // Image(systemName: self.selectMode ? "arrow.up.and.down.and.arrow.left.and.right" : "pencil.line")
                Image(systemName: self.selectMode ? "arrow.up.and.down.and.arrow.left.and.right" : "square.and.pencil")
                    .font(.system(size: 24, weight: .bold))
            }
            Button(action: {
                showSettings?()
                onAnyTap?()
            }) {
                Image(systemName: "gearshape.fill") // Settings icon
                    .font(.system(size: 24, weight: .bold))
            }
        }
        //
        // The padding-veritical controls how far from the bottom the control is;
        // greater is farther way  i.e. shifted upwards.
        //
        .padding(.vertical, 0)
        //
        // The frame-infinity make the control the width of the screen/view;
        // though minus horizontal padding inside background below.
        //
        .frame(maxWidth: .infinity)
        .background(
            //
            // The corner-radius controls how rounded the control window corners are;
            // greater is more rounded.
            //
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                //
                // This fill-thin-material makes the control background blend in with what is behind it.
                //
                .fill(.thinMaterial)
                //
                // This opacity controls how transparent the (background of) the control is.
                //
                .opacity(0.7)
                //
                // This frame-height controls the height of the control; default without this is fairly short.
                //
                .frame(height: 38)
                //
                // This padding-horizontal controls the internal left/right padding of control.
                //
                .padding(.horizontal, 20)
                //
                // This shadow-radius controls the soft drop shadow around/behind the control.
                // though can't really see a different with it on/off or high/low.
                //
                .shadow(radius: 10)
        )
        .onTapGesture { onAnyTap?() } // reset timer on any tap in control bar
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
