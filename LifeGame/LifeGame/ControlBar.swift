
import SwiftUI
import UIKit

struct ControlBar: View {
    var selectMode: (() -> Bool)
    var selectModeToggle: (() -> Void)
    var automationMode: (() -> Bool)
    var automationModeToggle: (() -> Void)
    var showSettings: (() -> Void)
    var erase: (() -> Void)

    var body: some View {
        HStack(spacing: 36) {
            ActionButton(automationModeToggle, "play.fill", iconToggle: "pause.fill", toggle: self.automationMode())
            ActionButton(selectModeToggle, "square.and.pencil", iconToggle: "arrow.up.and.down.and.arrow.left.and.right", toggle: self.selectMode())
            ActionButton(erase, "eraser")
            ActionButton(showSettings, "gearshape.fill")
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
        .onTapGesture {
            //
            // TODO: reset timer on any tap in control bar.
            //
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

public struct ActionButton: View {
    private let _action: (() -> Void)
    private let _icon: String
    private let _iconToggle: String
    private let _iconWidth: CGFloat = 24.0
    @State private var _toggle: Bool = false
    public init(_ action: @escaping (() -> Void), _ icon: String, iconToggle: String? = nil, toggle: Bool = false) {
        self._action = action
        self._icon = icon
        self._iconToggle = iconToggle ?? icon
        if (toggle) {
            self._toggle.toggle()
        }
        var x = 1
    }
    public var body: some View {
        Button(action: {
            self._action()
            self._toggle.toggle()
        }) {
            Image(systemName: self._toggle ? self._iconToggle : self._icon).font(.system(size: self._iconWidth, weight: .bold))
        }
    }
}
