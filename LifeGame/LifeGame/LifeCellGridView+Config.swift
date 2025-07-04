import Foundation
import SwiftUI
import CellGridView
import Utils

extension LifeCellGridView
{
    public class Config: CellGridView.Config
    {
        public var activeColor: Colour
        public var inactiveColor: Colour
        public var inactiveColorRandom: Bool
        public var inactiveColorRandomDynamic: Bool
        public var inactiveColorRandomPalette: ColourPalette
        public var inactiveColorRandomFilter: ColourFilter?
        public var variantHighLife: Bool
        public var variantOverpopulate: Bool

        public var dragThreshold: Int  = 3
        public var swipeThreshold: Int = 100
        public var soundEnabled: Bool  = false
        public var hapticEnabled: Bool = false

        // Initializes this instance of LifeCellGridView.Config with the properties from the given
        // Settings; or if this is nil then with the properties from the given LifeCellGridView;
        // or if that is nil then from the default values in Settings.Defaults.
        //
        // Note that this constructor does in fact effectively hide the base
        // class constructor which takes a CellGridView, which is what we want;
        // i.e. only allow creation of LifeCellGridView.Config with a LifeCellGridView.
        //
        // Note that the call to this with a Settings object (and non-nil LifeCellGridView object)
        // is done from the toConfig method of LifeCellGridView.Config. We do not just initialize
        // from Settings directly there because we need to initialize its CellGridView base class
        // properties, particularly those base properties which we are not interested in here.
        //
        internal init(_ cellGridView: LifeCellGridView? = nil, _ settings: Settings? = nil) {

            // Shorter names/aliases; to easier see/check what is being initialized here.

            let v: LifeCellGridView? = cellGridView
            let s: Settings?         = settings
            let d: Settings          = Settings.Defaults

            // LifeCellGridView specific properties.

            self.activeColor                = s?.activeColor                ?? v?.activeColor                ?? d.activeColor
            self.inactiveColor              = s?.inactiveColor              ?? v?.inactiveColor              ?? d.inactiveColor
            self.inactiveColorRandom        = s?.inactiveColorRandom        ?? v?.inactiveColorRandom        ?? d.inactiveColorRandom
            self.inactiveColorRandomDynamic = s?.inactiveColorRandomDynamic ?? v?.inactiveColorRandomDynamic ?? d.inactiveColorRandomDynamic
            self.inactiveColorRandomPalette = s?.inactiveColorRandomPalette ?? v?.inactiveColorRandomPalette ?? d.inactiveColorRandomPalette
            self.inactiveColorRandomFilter  = s?.inactiveColorRandomFilter  ?? v?.inactiveColorRandomFilter  ?? d.inactiveColorRandomFilter
            self.variantHighLife            = s?.variantHighLife            ?? v?.variantHighLife            ?? d.variantHighLife
            self.variantOverpopulate        = s?.variantOverpopulate        ?? v?.variantOverpopulate        ?? d.variantOverpopulate
            self.dragThreshold              = s?.dragThreshold              ?? v?.dragThreshold              ?? d.dragThreshold
            self.swipeThreshold             = s?.swipeThreshold             ?? v?.swipeThreshold             ?? d.swipeThreshold
            self.soundEnabled               = s?.soundEnabled               ?? v?.soundEnabled               ?? d.soundEnabled
            self.hapticEnabled              = s?.hapticEnabled              ?? v?.hapticEnabled              ?? d.hapticEnabled

            // CellGridView base class specific properties.

            super.init(viewBackground:     s?.viewBackground     ?? v?.viewBackground     ?? d.viewBackground,
                       viewTransparency:   s?.viewTransparency   ?? v?.viewTransparency   ?? d.viewTransparency,
                       viewScaling:        s?.viewScaling        ?? v?.viewScaling        ?? d.viewScaling,
                       cellSize:           s?.cellSize           ?? v?.cellSize           ?? d.cellSize,
                       cellPadding:        s?.cellPadding        ?? v?.cellPadding        ?? d.cellPadding,
                       cellShape:          s?.cellShape          ?? v?.cellShape          ?? d.cellShape,
                       cellShading:        s?.cellShading        ?? v?.cellShading        ?? d.cellShading,
                       gridColumns:        s?.gridColumns        ?? v?.gridColumns        ?? d.gridColumns,
                       gridRows:           s?.gridRows           ?? v?.gridRows           ?? d.gridRows,
                       fit:                s?.fit                ?? v?.fit                ?? d.fit,
                       center:             s?.center             ?? v?.center             ?? d.center,
                       cellAntialiasFade:  s?.cellAntialiasFade  ?? v?.cellAntialiasFade  ?? d.cellAntialiasFade,
                       cellRoundedRadius:  s?.cellRoundedRadius  ?? v?.cellRoundedRadius  ?? d.cellRoundedRadius,
                       restrictShift:      s?.restrictShift      ?? v?.restrictShift      ?? d.restrictShift,
                       unscaledZoom:       s?.unscaledZoom       ?? v?.unscaledZoom       ?? d.unscaledZoom,
                       selectMode:         s?.selectMode         ?? v?.selectMode         ?? d.selectMode,
                       automationMode:     s?.automationMode     ?? v?.automationMode     ?? d.automationMode,
                       automationInterval: s?.automationInterval ?? v?.automationInterval ?? d.automationInterval)
        }
    }
}
