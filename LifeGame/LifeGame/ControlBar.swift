import SwiftUI
import UIKit

struct ControlBar: View {

             var selectMode: (() -> Bool)
             var selectModeToggle: (() -> Void)
    @Binding var automationMode: Bool
             var automationModeToggle: (() -> Void)
             var automationStep: (() -> Void)
    @Binding var automationRandom: Bool
             var automationRandomToggle: (() -> Void)
             var showSettings: (() -> Void)
             var erase: (() -> Void)

    private func automationModeInternal() -> Bool {
        return self.automationMode
    }

    private func automationModeToggleInternal() {
        self.automationModeToggle()
        self.automationMode = !self.automationMode
    }

    private func automationRandomInternal() -> Bool {
        return self.automationRandom
    }

    private func automationRandomToggleInternal() {
        self.automationRandomToggle()
        self.automationRandom = !self.automationRandom
    }

    var body: some View {
        //
        // This spacing here controls the horizaontal distance between the icons.
        //
        HStack(spacing: 26) {
            ActionButton(self.automationModeToggleInternal, "play.fill",
                         actionToggled: self.automationModeInternal,
                         iconToggled: "pause.fill")
            ActionButton(self.automationStep, "arrow.forward.square")
            ActionButton(self.automationRandomToggleInternal, "swirl.circle.righthalf.filled",
                         actionToggled: self.automationRandomInternal,
                         iconToggled: "line.3.crossed.swirl.circle",
                         iconWidth: 22,
                         iconToggledWidth: 22)
            ActionButton(self.erase, "arrow.counterclockwise.circle")
            ActionButton(self.selectModeToggle, "square.and.pencil", actionToggled: self.selectMode,
                         iconToggled: "arrow.up.and.down.and.arrow.left.and.right",
                         //
                         // Some odd fine-tuning/fudging of the sizes here to prevent the control-bar from shifting around.
                         //
                         iconToggledWidth: 22, iconShiftY: -1)
            ActionButton(self.showSettings, "gear")
        }
        //
        // The padding-vertical controls how far from the bottom the control is;
        // greater is farther way i.e. shifted upwards.
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
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                //
                // This fill-thin-material makes the control background blend in with what is behind it.
                //
                .fill(.black)
                // .fill(.thinMaterial)
                //
                // This opacity controls how transparent the (background of) the control is.
                //
                .opacity(0.8)
                //
                // This frame-height controls the height of the control; default without this is fairly short.
                //
                .frame(height: 42)
                //
                // This padding-horizontal controls the internal left/right padding of control as a whole.
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
    private let _iconToggled: String
    private let _iconWidth: CGFloat
    private let _iconToggledWidth: CGFloat
    private let _iconShiftY: CGFloat
    private let _iconToggledShiftY: CGFloat
    private let _actionToggled: (() -> Bool)
    @State private var _toggled: Bool = false
    public init(_ action: @escaping (() -> Void),
                _ icon: String,
                actionToggled: (() -> Bool)? = nil,
                iconToggled: String? = nil,
                iconWidth: Int = 24, iconToggledWidth: Int = 24,
                iconShiftY: Int = 0, iconToggledShiftY: Int = 0) {
        self._action = action
        self._icon = icon
        self._iconToggled = iconToggled ?? icon
        self._iconWidth = CGFloat(iconWidth)
        self._iconToggledWidth = CGFloat(iconToggledWidth)
        self._iconShiftY = CGFloat(iconShiftY)
        self._iconToggledShiftY = CGFloat(iconToggledShiftY)
        self._actionToggled = actionToggled ?? { false }
    }
    public var body: some View {
        Button(action: {
            self._action()
            self._toggled = self._actionToggled()
        }) {
            Image(systemName: self._toggled ? self._iconToggled : self._icon)
                .foregroundColor(.white)
                .font(.system(size: self._toggled ? self._iconToggledWidth : self._iconWidth , weight: .light))
                .offset(y: self._toggled ? self._iconToggledShiftY : self._iconShiftY)
        }
        .onAppear {
            self._toggled = self._actionToggled()
        }
    }
}
