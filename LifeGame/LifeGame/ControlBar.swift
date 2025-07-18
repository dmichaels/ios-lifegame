import SwiftUI
import UIKit

struct ControlBar: View {

    @Binding var selectMode: Bool
             var selectModeToggle: (() -> Void)
    @Binding var automationMode: Bool
             var automationModeToggle: (() -> Void)
             var automationStep: (() -> Void)
    @Binding var selectRandomMode: Bool
             var selectRandomModeToggle: (() -> Void)
             var showSettings: (() -> Void)
             var erase: (() -> Void)

    var body: some View {
        //
        // This spacing on the HStack controls the horizaontal distance between the icons.
        // Also note some odd fine-tuning/fudging of icon-specific sizing and/or
        // positioning (e.g. iconWidth). to prevent the ControlBar from shifting around.
        // And note that we have to say, for example, $selectMode rather than $self.selectMode,
        // as the $ is just Swift syntactic sugar which does not understand a self qualifier.
        //
        HStack(spacing: 26) {
            ActionButton(toggle: $automationMode,
                         action: self.automationModeToggle,
                         icon: "play.fill",
                         iconToggled: "pause.fill")
            ActionButton(action: self.automationStep,
                         icon: "arrow.forward.square")
            ActionButton(toggle: $selectRandomMode,
                         action: self.selectRandomModeToggle,
                         icon: "swirl.circle.righthalf.filled",
                         iconToggled: "line.3.crossed.swirl.circle",
                         iconWidth: 22,
                         iconToggledWidth: 22)
            ActionButton(action: self.erase, icon: "arrow.counterclockwise.circle")
            ActionButton(toggle: $selectMode,
                         action: self.selectModeToggle,
                         icon: "square.and.pencil",
                         iconToggled: "arrow.up.and.down.and.arrow.left.and.right",
                         iconShiftY: -1,
                         iconToggledWidth: 22)
            ActionButton(action: self.showSettings, icon: "gear")
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

    private let action: (() -> Void)?
    private let icon: String
    private let iconWidth: CGFloat
    private let iconShiftY: CGFloat

    @Binding private var toggle: Bool
    private let iconToggled: String
    private let iconToggledWidth: CGFloat
    private let iconToggledShiftY: CGFloat
    private let toggleButton: Bool

    public init(action: @escaping (() -> Void),
                icon: String,
                iconWidth: Int = 24,
                iconShiftY: Int = 0) {
        self.toggleButton = false
        //
        // Note that self._toggle is the Swift-internal representation of self.toggle.
        //
        self._toggle = .constant(false)
        self.action = action
        self.icon = icon
        self.iconWidth = CGFloat(iconWidth)
        self.iconShiftY = CGFloat(iconShiftY)
        self.iconToggled = icon // unused
        self.iconToggledWidth = CGFloat(0) // unused
        self.iconToggledShiftY = CGFloat(0) // unused
    }

    public init(toggle: Binding<Bool>,
                action: (() -> Void)? = nil,
                icon: String,
                iconToggled: String,
                iconWidth: Int = 24,
                iconShiftY: Int = 0,
                iconToggledWidth: Int = 24,
                iconToggledShiftY: Int = 0) {
        self.toggleButton = true
        //
        // Note that self._toggle is the Swift-internal representation of self.toggle.
        //
        self._toggle = toggle
        self.action = action
        self.icon = icon
        self.iconToggled = iconToggled
        self.iconWidth = CGFloat(iconWidth)
        self.iconShiftY = CGFloat(iconShiftY)
        self.iconToggledWidth = CGFloat(iconToggledWidth)
        self.iconToggledShiftY = CGFloat(iconToggledShiftY)
    }

    public var body: some View {
        Button(action: {
            if (self.toggleButton) {
                toggle.toggle()
            }
            if let action = self.action {
                action()
            }
        }) {
            Image(systemName: self.toggleButton && self.toggle ? self.iconToggled : self.icon)
                .foregroundColor(.white)
                .font(.system(size: self.toggleButton && self.toggle
                                    ? self.iconToggledWidth
                                    : self.iconWidth , weight: .light))
                .offset(y: self.toggleButton && self.toggle
                           ? self.iconToggledShiftY
                           : self.iconShiftY)
        }
    }
}
