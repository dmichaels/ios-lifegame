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
        public var inactiveColorRandomPalette: ColourMode
        public var inactiveColorRandomFilter: ColourFilter?

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

            // Life Game specific properties.

            self.activeColor                = s?.activeColor                ?? v?.activeColor                ?? d.activeColor
            self.inactiveColor              = s?.inactiveColor              ?? v?.inactiveColor              ?? d.inactiveColor
            self.inactiveColorRandom        = s?.inactiveColorRandom        ?? v?.inactiveColorRandom        ?? d.inactiveColorRandom
            self.inactiveColorRandomDynamic = s?.inactiveColorRandomDynamic ?? v?.inactiveColorRandomDynamic ?? d.inactiveColorRandomDynamic
            self.inactiveColorRandomPalette = s?.inactiveColorRandomPalette ?? v?.inactiveColorRandomPalette ?? d.inactiveColorRandomPalette
            self.inactiveColorRandomFilter  = s?.inactiveColorRandomFilter  ?? v?.inactiveColorRandomFilter  ?? d.inactiveColorRandomFilter
            self.dragThreshold              = s?.dragThreshold              ?? v?.dragThreshold              ?? d.dragThreshold
            self.swipeThreshold             = s?.swipeThreshold             ?? v?.swipeThreshold             ?? d.swipeThreshold
            self.soundEnabled               = s?.soundEnabled               ?? v?.soundEnabled               ?? d.soundEnabled
            self.hapticEnabled              = s?.hapticEnabled              ?? v?.hapticEnabled              ?? d.hapticEnabled

            // CellGridView base class specific properties.

            super.init(cellGridView)

            super.viewBackground     = s?.viewBackground     ?? v?.viewBackground     ?? d.viewBackground
            super.viewTransparency   = s?.viewTransparency   ?? v?.viewTransparency   ?? d.viewTransparency
            super.viewScaling        = s?.viewScaling        ?? v?.viewScaling        ?? d.viewScaling
            super.cellSize           = s?.cellSize           ?? v?.cellSize           ?? d.cellSize
            super.cellPadding        = s?.cellPadding        ?? v?.cellPadding        ?? d.cellPadding
            super.cellShape          = s?.cellShape          ?? v?.cellShape          ?? d.cellShape
            super.gridColumns        = s?.gridColumns        ?? v?.gridColumns        ?? d.gridColumns
            super.gridRows           = s?.gridRows           ?? v?.gridRows           ?? d.gridRows
            super.restrictShift      = s?.restrictShift      ?? v?.restrictShift      ?? d.restrictShift
            super.unscaledZoom       = s?.unscaledZoom       ?? v?.unscaledZoom       ?? d.unscaledZoom
            super.cellAntialiasFade  = s?.cellAntialiasFade  ?? v?.cellAntialiasFade  ?? d.cellAntialiasFade
            super.cellRoundedRadius  = s?.cellRoundedRadius  ?? v?.cellRoundedRadius  ?? d.cellRoundedRadius
            super.selectMode         = s?.selectMode         ?? v?.selectMode         ?? d.selectMode
            super.automationMode     = s?.automationMode     ?? v?.automationMode     ?? d.automationMode
            super.automationInterval = s?.automationInterval ?? v?.automationInterval ?? d.automationInterval
        }
    }
}
